# frozen_string_literal: true

require 'httparty'
require 'json'
require 'securerandom'
require 'ruby-progressbar'
require 'puppeteer-ruby'
require 'logger'

Database.connect

require_relative '../config/db/db_config'
require_relative '../models/college'

# Redirect STDERR to a log file
log_file = File.open('errors.log', 'w')
log_file.sync = true
$stderr.reopen(log_file)
logger = Logger.new(log_file)

class CollegeCrawler
  BASE_API_URL = 'https://cs-search-api-prod.collegeplanning-prod.collegeboard.org/colleges'
  COLLEGE_PAGE_BASE_URL = 'https://bigfuture.collegeboard.org/colleges'
  FILTER_PAGE_URL = 'https://bigfuture.collegeboard.org/college-search/filters'

  def initialize(dry_run: false, batch_size: 50)
    @batch_size = batch_size
    @dry_run = dry_run
  end

  def run
    total_hits = fetch_total_colleges
    from = 0

    print_script_overview
    progress_bar = create_progress_bar(total_hits)

    while from < total_hits
      colleges = fetch_colleges(from)
      process_colleges(colleges, progress_bar)

      from += @batch_size
      sleep(rand(1..5))
    end

    puts @dry_run ? '🧪 Dry run completed. No data was inserted.' : '⚡️ Data scraping and insertion completed.'
  end

  private

  def print_script_overview
    puts "🧪 Dry run detected: #{@dry_run}"
    puts "🔍 Batch size: #{@batch_size}"
    puts "🥷 Colleges at #{FILTER_PAGE_URL} will be scraped..."
    puts "🔍 Total colleges found: #{fetch_total_colleges}"
    puts '🌀 Processing...'
  end

  def fetch_total_colleges
    max_retries = 15
    retries = 0

    begin
      Puppeteer.launch(headless: true, timeout: 60_000) do |browser|
        page = browser.new_page
        page.goto(FILTER_PAGE_URL)

        total_colleges_element = page.wait_for_selector(
          'div[id="cs-show-number-of-results"] span',
          timeout: 60_000
        )
        total_colleges_element.evaluate(
          'element => element.textContent'
        ).strip.to_i
      end
    rescue Puppeteer::Connection::ProtocolError, Puppeteer::TimeoutError => e
      retries += 1
      if retries <= max_retries
        sleep(2**retries)
        retry
      else
        logger.error("F, Failed to fetch total colleges count after #{max_retries} attempts.")
        return 0
      end
    end
  end

  def create_progress_bar(total_hits)
    ProgressBar.create(
      total: total_hits,
      format: '%a |%b%i| %p%% %t | %c/%C | %e',
      progress_mark: '█',
      remainder_mark: '░'
    )
  end

  def fetch_colleges(from)
    max_retries = 15
    retries = 0

    begin
      response = HTTParty.post(
        BASE_API_URL,
        headers: { 'Content-Type' => 'application/json' },
        body: {
          eventType: 'search',
          eventData: {
            config: {
              size: @batch_size,
              from: from,
              highlight: 'name'
            },
            criteria: {
              rmsInputField: '',
              rmsInputValue: ''
            }
          }
        }.to_json
      )
      return JSON.parse(response.body)['data']
    rescue HTTParty::Error, JSON::ParserError => e
      retries += 1
      if retries <= max_retries
        sleep(2**retries)
        retry
      else
        logger.error("F, Failed to fetch additional batch size of #{@batch_size} "\
          "from index #{from} after #{max_retries} attempts.")
        return []
      end
    end
  end

  def process_colleges(colleges, progress_bar)
    colleges.each do |college|
      name = college['name']
      city = college['city']
      state = college['state']
      vanity_uri = college['vanityUri']

      college_page_url = "#{COLLEGE_PAGE_BASE_URL}/#{vanity_uri}"
      college_board_code = fetch_college_board_code(college_page_url)

      if @dry_run
        puts "DRY RUN - Would insert: #{name}, #{city}, #{state}, #{college_board_code}"
      else
        create_college!(name, city, state, college_board_code)
      end

      progress_bar.increment
      sleep(rand(1..5))
    end
  end

  def create_college!(name, city, state, college_board_code)
    return if College.where(name:).count.positive?

    begin
      College.create(
        name:,
        city:,
        state:,
        college_board_code:
      )
    rescue StandardError => e
      logger.error("F, Failed to create college #{name}, #{city}, #{state}, #{college_board_code}. Error: #{e.message}")
    end
  end

  def fetch_college_board_code(college_page_url)
    max_retries = 15
    retries = 0

    begin
      Puppeteer.launch(headless: true) do |browser|
        page = browser.new_page
        page.goto(college_page_url)
        college_board_code_element = page.wait_for_selector('div[data-testid="csp-more-about-college-board-code-valueId"]', visible: false, timeout: 60_000)
        college_board_code_element.evaluate('element => element.textContent').strip
      end
    rescue Puppeteer::Connection::ProtocolError, Puppeteer::TimeoutError => e
      retries += 1
      if retries <= max_retries
        sleep(2**retries)
        retry
      else
        logger.error("F, Failed to fetch college board code for #{college_page_url}")
        return nil
      end
    end
  end
end
