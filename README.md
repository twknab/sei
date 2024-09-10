# Strategic Education, Inc. Coding Assessment

// TODO: Add description

## How to Setup & Run

> ℹ️ **Info:** You may need to look up the correct installation method if running Windows or another operating system. These instructions are for Mac running on Apple Silicon using homebrew.

### Step 1: Install Ruby and RVM (Mac)

This is a ruby project, so you'll need to have ruby installed on your machine with the correct version utilized in the project. Using a version manager is recommended.

1. Ruby: Install ruby on your machine
   - `brew install ruby`
2. Install a ruby version manager like `rvm` (or your preferred version manager)
   - `brew install rvm`
3. Install the ruby version specified in the `.ruby-version` file (3.2.2):
   - `rvm install 3.2.2`
4. Set your system ruby to the version specified in the `.ruby-version` file (3.2.2)
   - `rvm use 3.2.2`

### Step 2: Install PostgreSQL

We'll be using PostgreSQL to store the scraped college data, and will need to install it on our machine.

1. Install PostgreSQL
   - `brew install postgresql`
2. Ensure PostgreSQL is running on your machine
   - `brew services start postgresql`

### Step 3: Setup the Database

We need to setup the database and create the `colleges` table, to store the scraped college data.

<!-- TODO: Add instructions on setting up database environmental variables if needed -->
1. Run `bundle install` to install the gems specified in the `Gemfile`
2. Run `rake db:create` to create the database and test_database (for specs)
3. Run `rake db:migrate` to run migrations (will create the `colleges` table)
4. How to drop (if needed): Run `rake db:drop`

### Step 4: Run the College Crawler script 🎉

You may now execute the college crawler script to scrape the College Board website and populate the database with data.

- Run `rake scrape` (or just `rake` since the scrape is the default task) to crawl the College Board website and populate the database with data.
  - This may take awhile to complete and will populate the database with college data.

### Step 5: Run the tests (if you wish)

- Run `rake spec` to run the tests for the script and model.
  - You can also use the command `rspec .` to run the tests

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

## Technical Concerns

// TODO: Add technical concerns

## Improvements

- Would be nice to add automated testing suite that runs on CI/CD pipeline
- Would be nice to add a frontend to the application to allow users to search for colleges by name, city, state, etc.
- Would be nice to offer a public API to allow users to search for colleges by name, city, state, etc.

## Thank You Note

// TODO: Add thank you note
