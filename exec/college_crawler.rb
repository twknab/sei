# frozen_string_literal: true

require 'httparty'
require 'capybara'
require 'selenium-webdriver'
require 'json'
require 'securerandom'
require 'ruby-progressbar'

Database.connect

require_relative '../config/db/db_config'
require_relative '../models/college'

class CollegeCrawler
  BASE_API_URL = 'https://cs-search-api-prod.collegeplanning-prod.collegeboard.org/colleges'
  COLLEGE_PAGE_BASE_URL = 'https://bigfuture.collegeboard.org/colleges'
  FILTER_PAGE_URL = 'https://bigfuture.collegeboard.org/college-search/filters'

  def initialize(dry_run: false, batch_size: 50)
    @batch_size = batch_size
    @dry_run = dry_run
  end

  def fetch_total_colleges
    session = Capybara::Session.new(:selenium_chrome_headless)
    session.visit(FILTER_PAGE_URL)
    total_colleges_element = session.find('div[id="cs-show-number-of-results"] span')

    total_colleges_element.text.strip.to_i
  end

  def run
    total_hits = fetch_total_colleges
    from = 0

    puts '🧪 Dry run detected, no data will be inserted' if @dry_run
    puts "Total colleges found: #{total_hits}"
    puts 'Processing...'

    progress_bar = ProgressBar.create(
      total: total_hits,
      format: '%a |%b%i| %p%% %t | %c/%C',
      progress_mark: '█',
      remainder_mark: '░'
    )

    while from < total_hits
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

      data = JSON.parse(response.body)
      colleges = data['data']

      # Process each college and make an additional GET request to scrape the board code
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
          unless College.where(name:).count.positive?
            College.create(
              name:,
              city:,
              state:,
              college_board_code:
            )
          end
        end

        progress_bar.increment
      end

      from += @batch_size
      sleep(rand(1..5))

    end
    puts @dry_run ? '🧪 Dry run completed. No data was inserted.' : '⚡️ Data scraping and insertion completed.'
  end

  # Scrape the college board code from the individual college page
  def fetch_college_board_code(college_page_url)
    max_retries = 15
    retries = 0

    begin
      session = Capybara::Session.new(:selenium_chrome_headless)

      # Set Capybara's default timeout to give more time for loading latency
      Capybara.default_max_wait_time = 15

      session.visit(college_page_url)

      begin
        college_board_code_element = session.find(
          'div[data-testid="csp-more-about-college-board-code-valueId"]',
          visible: false
        )
        college_board_code_element&.text&.strip
      rescue Capybara::ElementNotFound
        nil
      end
    rescue Net::ReadTimeout, Selenium::WebDriver::Error::TimeoutError => e
      retries += 1
      if retries <= max_retries
        puts "Timeout occurred, retrying... (#{retries}/#{max_retries})"
        sleep(2**retries)
        retry
      else
        puts "Failed after #{max_retries} attempts: #{e.message}"
        nil
      end
    end
  end
end
