# frozen_string_literal: true

require 'sequel'

module Database
  # TODO: move these values into environment variables so not visible in repository
  def self.config
    {
      adapter: 'postgresql',
      database: 'colleges',
      username: 'postgres',
      password: 'postgres',
      host: 'localhost'
    }
  end

  # TODO: move these values into environment variables so not visible in repository
  def self.test_config
    {
      adapter: 'postgresql',
      database: 'colleges_test',
      username: 'postgres',
      password: 'postgres',
      host: 'localhost'
    }
  end

  def self.connect
    db = Sequel.connect(config)
    Sequel::Model.db = db
    db
  end

  def self.connect_test
    db = Sequel.connect(test_config)
    Sequel::Model.db = db
    db
  end

  def self.migrate
    Rake::Task['db:migrate'].invoke
  end
end
