# frozen_string_literal: true

require 'sequel'

module Database
  # TODO: move these values into environment variables so not visible in repository
  def self.config
    {
      adapter: 'postgresql',
      database: 'college_db',
      username: 'postgres',
      password: 'postgres',
      host: 'localhost'
    }
  end

  # TODO: move these values into environment variables so not visible in repository
  def self.test_config
    {
      adapter: 'postgresql',
      database: 'college_db_test',
      username: 'postgres',
      password: 'postgres',
      host: 'localhost'
    }
  end

  def self.connect
    Sequel.connect(config)
  end

  def self.connect_test
    Sequel.connect(test_config)
  end

  def self.migrate
    Rake::Task['db:migrate'].invoke
  end
end
