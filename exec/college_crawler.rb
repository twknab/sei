# frozen_string_literal: true

require 'httparty'
require 'json'
require 'securerandom'
require 'ruby-progressbar'
require 'puppeteer-ruby'

Database.connect

require_relative '../config/db/db_config'
require_relative '../config/logging_config'
require_relative '../models/college'

# CollegeCrawler is responsible for scraping college data from the College Board
# API and processing it for storage in the database.
#
# It does the following tasks:
#
# - Fetches initial and subsequent batches of college data from the API.
# - Displays progress and ETA information to the user.
# - Processes each college's data, including fetching additional details from
#   the college's webpage.
# - Inserts the processed data into the database.
#
# Usage:
#   CollegeCrawler.new.run
#
# See `errors.log` for any failures.
#
# Dependencies:
#   - HTTParty: For making HTTP requests to the College Board API.
#   - Puppeteer: For scraping additional details from college webpages.
#   - Sequel: For interacting with the database.
#   - Logger: For logging and failures.
#
class CollegeCrawler
  BASE_API_URL = 'https://cs-search-api-prod.collegeplanning-prod.collegeboard.org/colleges'
  COLLEGE_PAGE_BASE_URL = 'https://bigfuture.collegeboard.org/colleges'
  FILTER_PAGE_URL = 'https://bigfuture.collegeboard.org/college-search/filters'

  def initialize
    @batch_size = 50
    @logger = LoggingConfig.setup
  end

  def run
    # Make initial request to API to retrieve total hits with first batch
    total_hits, initial_colleges = fetch_initial_colleges

    display_script_info(total_hits)
    progress_bar = display_progress_bar(total_hits)

    # Process initial batch of colleges and subsequent batches
    process_colleges(initial_colleges, progress_bar)
    fetch_and_process_remaining_colleges(total_hits, progress_bar)

    puts '⚡️ Data scraping and insertion completed.'
  end

  private

  def fetch_initial_colleges
    from = 0
    response = fetch_college_batch(from)

    total_hits = response['totalHits']
    initial_colleges = response['data']

    [total_hits, initial_colleges]
  end

  def display_script_info(total_hits)
    puts "✨ Let's steal some data! 💸"
    puts "🥷 Colleges at #{FILTER_PAGE_URL} will be scraped..."
    puts "🔍 Total colleges found: #{total_hits}"
    puts '🌀 Processing...'
  end

  def display_progress_bar(total_hits)
    ProgressBar.create(
      total: total_hits,
      format: '%a |%b%i| %p%% %t | %c/%C | %e',
      progress_mark: '█',
      remainder_mark: '░'
    )
  end

  def fetch_and_process_remaining_colleges(total_hits, progress_bar)
    from = @batch_size
    while from < total_hits
      colleges = fetch_college_batch(from)['data']
      process_colleges(colleges, progress_bar)

      from += @batch_size

      # Throttle the requests to avoid being rate-limited
      sleep(rand(1..5))
    end
  end

  def fetch_college_batch(from)
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
      JSON.parse(response.body)
    rescue HTTParty::Error, JSON::ParserError => e
      retries += 1

      if retries <= max_retries
        sleep(2**retries)
        retry
      else
        @logger.error("F, Failed to fetch batch size of #{@batch_size} "\
          "from index #{from} after #{max_retries} attempts. "\
          "Error: #{e.message}")
        []
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

      create_college!(name, city, state, college_board_code)

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
      @logger.error("F, Failed to create college #{name}, #{city}, #{state}, "\
        "#{college_board_code}. Error: #{e.message}")
    end
  end

  def fetch_college_board_code(college_page_url)
    max_retries = 15
    retries = 0

    begin
      scrape_college_board_code(college_page_url)
    rescue Puppeteer::Connection::ProtocolError, Puppeteer::TimeoutError,
           Puppeteer::LifecycleWatcher::TerminatedError, Timeout::Error => e
      retries += 1
      if retries <= max_retries
        sleep(2**retries)
        retry
      else
        @logger.error('F, Failed to fetch college board code for '\
          "#{college_page_url}. Error: #{e.message}")
        nil
      end
    end
  end

  def scrape_college_board_code(college_page_url)
    Puppeteer.launch(headless: true, timeout: 60_000) do |browser|
      page = browser.new_page
      page.goto(college_page_url, timeout: 60_000)
      college_board_code_element = page.wait_for_selector(
        'div[data-testid="csp-more-about-college-board-code-valueId"]',
        visible: false,
        timeout: 60_000
      )
      college_board_code_element.evaluate(
        'element => element.textContent'
      ).strip
    end
  end
end
