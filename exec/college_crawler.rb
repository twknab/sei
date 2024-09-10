# frozen_string_literal: true

require 'httparty'
require 'nokogiri'
require 'json'
require 'securerandom'
require 'ruby-progressbar'

require_relative '../config/db/db_config'

class CollegeCrawler
  BASE_API_URL = 'https://cs-search-api-prod.collegeplanning-prod.collegeboard.org/colleges'
  COLLEGE_PAGE_BASE_URL = 'https://bigfuture.collegeboard.org/colleges'
  FILTER_PAGE_URL = 'https://bigfuture.collegeboard.org/college-search/filters'

  def initialize(dry_run: false, batch_size: 50)
    @batch_size = batch_size
    @dry_run = dry_run
    @db = Database.connect
  end

  def fetch_total_colleges
    filter_page_response = HTTParty.get(FILTER_PAGE_URL)
    filter_page = Nokogiri::HTML(filter_page_response.body)
    total_colleges_element = filter_page.at_css('div[data-testid="cs-show-number-of-results"] span')

    binding.break
    total_colleges_element.text.strip.to_i
  end

  def run
    total_hits = fetch_total_colleges

    puts "Total colleges found: #{total_hits}"
    puts 'Processing...'

    # TODO: Should this be starting at 0 or 1 -- not sure if index yet?
    from = 0

    progress_bar = ProgressBar.create(
      total: total_hits,
      format: '%a |%b>>%i| %p%% %t'
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

        sleep(rand(1..5))
        college_board_code = fetch_college_board_code(college_page_url)

        if @dry_run
          puts "DRY RUN - Would insert: #{name}, #{city}, #{state}, #{college_board_code}"
        else
          @db[:colleges].insert(
            name:,
            city:,
            state:,
            college_board_code:
          )
        end

        progress_bar.increment
      end

      from += @batch_size
      sleep(rand(1..5))

      puts @dry_run ? '🧪 Dry run completed. No data was inserted.' : '⚡️ Data scraping and insertion completed.'
    end
  end

  # Scrape the college board code from the individual college page
  def fetch_college_board_code(college_page_url)
    response = HTTParty.get(college_page_url)
    page = Nokogiri::HTML(response.body)

    college_board_code_element = page.at_css('div[data-testid="csp-more-about-college-board-code-valueId"]')

    # TODO: Dig into this a bit more
    college_board_code_element&.text&.strip || nil
  end
end
