# Strategic Education, Inc. Coding Assessment

// TODO: Add description

## How to Run

// TODO: Add instructions on how to run

### Install Ruby and RVM

1. Ruby: Install ruby on your machine (//TODO: Add more details for system)
2. Install a ruby version manager like `rbenv` or `rvm`
3. Install the ruby version specified in the `.ruby-version` file (3.2.2)

### Install PostgreSQL

1. Install PostgreSQL on your machine (//TODO: Add more details for system)
2. Ensure PostgreSQL is running on your machine

### Setup the Database

<!-- TODO: Discuss setting up database environmental variables -->
1. Run `bundle install` to install the gems specified in the `Gemfile`
2. Run `rake db:create` to create the database
3. Run `rake db:migrate` to run migrations (will create the `colleges` table)
4. How to drop (if needed): Run `rake db:drop`

### Run the College Crawler script

- Run `rake scrape` to scrape the college data from the College Board website provided in `CollegeCrawler` (`/exec/college_crawler.rb`)
  - This may take awhile to complete and will populate the database with college data.

### Run the tests

- Run `rake test` to run the tests for the scripts and models.
<!-- 7. Run `rake db:seed` to seed the database with the college data -->
<!-- TODO: Do we need to see anything? Will we have a development environment / test database? This isn't a running server -->

// TODO: Need to discuss how to setup ruby version and install ruby on your machine
// TODO: Need to discuss how to install postgres on your machine

## Technologies Used

- Ruby: humancentric language related to SEI's stack, allowing us to write a script to scrape the College Board website for college data.
- Sequel: allows us to interact with the database via an ORM, and gives us the advantages of migrations, validations, and more.
- HTTParty: allows us to make HTTP requests to the College Board API.
- Nokogiri: allows us to parse the HTML response from the College Board API.
- RSpec: allows us to write tests for our script.
- FactoryBot: allows us to create test data for our `College` model.
- Faker: allows us to create realistic test data for our `College` model.
- PostgreSQL: allows us to store the scraped college data in a database that's scalable and can be indexed and searched.
  - //TODO: Add more details on how we're using PostgreSQL

## Features

// TODO: Add features

## Technical Concerns & Improvements

// TODO: Add technical concerns & improvements

## Thank You Note

// TODO: Add thank you note
