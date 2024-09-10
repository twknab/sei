# frozen_string_literal: true

require 'rake'
require 'sequel'
require 'rspec/core/rake_task'

require_relative './config/db/db_config'

namespace :db do
  desc "Create the database"
  task :create do
    db_config = Database.config
    [Database.config, Database.test_config].each do |db_config|
      success = system("createdb #{db_config[:database]} -U #{db_config[:username]} -h #{db_config[:host]}")
      puts "Database #{db_config[:database]} created successfully" if success
    end

    Database.connect

    db = Database.db
    unless db.table_exists?(:schema_migrations)
      db.create_table :schema_migrations do
        primary_key :id
        String :filename, null: false
      end
    end
  rescue => e
    puts "Failed to create database: #{e.message}"
  end

  desc "Run database migrations"
  task :migrate do
    Database.connect

    Sequel.extension :migration
    Sequel::Migrator.run(Database.db, 'db/migrate')

    puts "Migrations ran successfully"
  rescue => e
    puts "Failed to run migrations: #{e.message}"
  end

  desc "Rollback the last database migration"
  task :rollback do
    Database.connect

    Sequel.extension :migration
    Sequel::Migrator.run(Database.db, 'db/migrate', target: 0)
  end

  desc "Drop the database (use with caution)"
  task :drop do
    [Database.config, Database.test_config].each do |db_config|
      success = system("dropdb -U #{db_config[:username]} -h #{db_config[:host]} #{db_config[:database]}")
      puts "Database #{db_config[:database]} dropped successfully" if success
    end
  rescue => e
    puts "Failed to drop database: #{e.message}"
  end
end

desc "Run the college crawler"
task :scrape do
  throw "Not safe yet"
  require_relative './exec/college_crawler'
  crawler = CollegeCrawler.new
  crawler.scrape_all_colleges
end

desc "Run RSpec tests"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

task default: :scrape