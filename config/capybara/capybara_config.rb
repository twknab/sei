# frozen_string_literal: true

require 'capybara'
require 'selenium-webdriver'

module CapybaraSetup
  def self.configure
    register_selenium_chrome_headless
    Capybara.default_driver = :selenium_chrome_headless
    Capybara.default_max_wait_time = 10
  end

  def self.register_selenium_chrome_headless
    Capybara.register_driver :selenium_chrome_headless do |app|
      options = selenium_chrome_options
      http_client = selenium_http_client

      Capybara::Selenium::Driver.new(
        app,
        browser: :chrome,
        options:,
        http_client:
      )
    end
  end

  def self.selenium_chrome_options
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options
  end

  def self.selenium_http_client
    http_client = Selenium::WebDriver::Remote::Http::Default.new
    http_client.read_timeout = 180
    http_client
  end
end

CapybaraSetup.configure
