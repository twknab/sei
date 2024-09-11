# frozen_string_literal: true

require 'httparty'
require 'json'
require 'securerandom'
require 'ruby-progressbar'

Database.connect

require_relative '../config/db/db_config'
require_relative '../config/capybara/capybara_config'
require_relative '../models/college'

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

    puts '🧪 Dry run detected, no data will be inserted' if @dry_run
    puts "Total colleges found: #{total_hits}"
    puts 'Processing...'

    progress_bar = create_progress_bar(total_hits)

    while from < total_hits
      Capybara.reset_sessions! if (from % 100).zero?

      colleges = fetch_colleges(from)
      process_colleges(colleges, progress_bar)

      from += @batch_size
      sleep(rand(1..5))
    end

    puts @dry_run ? '🧪 Dry run completed. No data was inserted.' : '⚡️ Data scraping and insertion completed.'
  end

  private

  def fetch_total_colleges
    session = Capybara::Session.new(:selenium_chrome_headless)
    session.visit(FILTER_PAGE_URL)
    total_colleges_element = session.find('div[id="cs-show-number-of-results"] span')

    total_colleges_element.text.strip.to_i
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
    response = HTTParty.post(
      BASE_API_URL,
      headers: { 'Content-Type' => 'application/json' },
      body: {
        eventType: 'search',
        eventData: {
          config: {
            size: @batch_size,
            from:,
            highlight: 'name'
          },
          criteria: {
            rmsInputField: '',
            rmsInputValue: ''
          }
        }
      }.to_json
    )
    JSON.parse(response.body)['data']
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
    end
  end

  def create_college!(name, city, state, college_board_code)
    return if College.where(name:).count.positive?

    College.create(
      name:,
      city:,
      state:,
      college_board_code:
    )
  end

  def fetch_college_board_code(college_page_url)
    max_retries = 15
    retries = 0

    begin
      session = Capybara::Session.new(:selenium_chrome_headless)
      session.visit(college_page_url)
      college_board_code_element = session.find(
        'div[data-testid="csp-more-about-college-board-code-valueId"]',
        visible: false
      )
      college_board_code_element&.text&.strip
    rescue Capybara::ElementNotFound
      nil
    rescue Selenium::WebDriver::Error::WebDriverError,
           Net::ReadTimeout,
           Selenium::WebDriver::Error::TimeoutError => e
      retries += 1
      if retries <= max_retries
        puts "Timeout or WebDriver error occurred, retrying... (#{retries}/#{max_retries})"
        sleep(2**retries)
        retry
      else
        puts "Failed after #{max_retries} attempts: #{e.message}"
        nil
      end
    end
  end
end
