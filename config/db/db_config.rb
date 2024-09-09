# frozen_string_literal: true

require 'sequel'

module Database
  def self.config
    {
      adapter: 'postgresql',
      database: 'college_db',
      username: 'postgres',
      password: 'postgres',
      host: 'localhost'
    }
  end

  def self.connect
    @db = Sequel.connect(config)
  end

  def self.migrate
    Rake::Task['db:migrate'].invoke
  end

  def self.db
    @db
  end
end
