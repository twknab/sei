# frozen_string_literal: true

require 'logger'

# Configuration for the logger, routes everything to `errors.log`
module LoggingConfig
  def self.setup
    log_file = File.open('errors.log', 'w')
    log_file.sync = true
    $stderr.reopen(log_file)
    Logger.new(log_file)
  end
end
