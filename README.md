# Strategic Education, Inc. Coding Assessment

This project is a college crawler that scrapes the [College Board website](https://bigfuture.collegeboard.org/college-search/filters) for college data and stores it in a PostgreSQL database. Ruby is used to write the script, along with a handful of gems to assist with web scraping actions, database interactions, code quality, and more.

## 🚀 Quick Start

If you already have the correct ruby version installed, and Postgres running, you can run the script quickly with the following commands:

```bash
rake db:create # to create the database
rake db:migrate # to create the colleges table
rake # to scrape the colleges
```

## 📷 Screenshots
<!-- TODO: Add screenshot of script running -->
<!-- TODO: Add screenshot of database snapshot table -->

## 📋 Project Setup

> ℹ️ **Info:** You may need to look up the correct installation method for a given step if running Windows or another operating system. These instructions are for Mac running on Apple Silicon using homebrew.

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

We'll be using PostgreSQL to store the scraped college data, and will need to install it on our machine. If you're having any trouble installing or running postgres through homebrew, you can also download postgres and run the service using [Postgres.app](https://postgresapp.com/downloads.html) for Mac.

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

## 🕷️ Run the College Crawler

After setting up the project, may now execute the college crawler script to scrape the College Board website and populate the database with data.

> ℹ️ **Info:** This script supports custom arguments: `batch_size` and `dry_run`.

```bash
rake
```

This will take awhile to complete and will populate the database with college data.

### Dry Run or Custom Batch Size

If you wish to dry run the script first:

- To run a dry run, pass in true as the first argument: `rake scrape[true]`
  - Dry run mode is false by default, because this script is intended to be executed as default behavior.

- To run a custom batch size, you can pass in your desired value (ex: `100`) like this: `rake scrape[false, 100]`. This would run the script with dry mode off, and a batch size of 100. You may also turn dry mode on via `rake script[true, 100]`
  - Warning: If you choose a batch size that is too large, you may run into errors due to the College Board API rate limiting, or get your IP address banned. Consider using a VPN or proceeding with caution.

### 🧪 Run Tests

- Run `rake spec` to run the tests for the script and model.
  - You can also use the command `rspec .` to run the tests

## 🛸 Technologies Used

### Language

- Ruby: humancentric language related to SEI's stack, allowing us to write a script to scrape the College Board website for college data.

### Web Scraping

- Sequel: allows us to interact with the database via an ORM, and gives us the advantages of migrations, validations, and more.
- HTTParty: allows us to make HTTP requests to the College Board API (used for the POST request to the API).
- Capybara: Allows us to write UI interactions that we would like to perform (we'll use Selenium Webdriver under the hood for browser interactions).
- Selenium Webdriver: Allows us to interact with the college board website and supports JavaScript We use this to scrape college data we can't get from our API search POST request.
- Ruby-ProgressBar: allows us to display a progress bar for the script.

### Testing

- RSpec: allows us to write tests for our script.
- FactoryBot: allows us to create test data for our `College` model.
- Faker: allows us to create realistic test data for our `College` model.

### Database

- PostgreSQL: allows us to store the scraped college data in a database that's scalable and can be indexed and searched.
  - TODO: Add more detail why we're using PostgreSQL
  
### Debugging and Code Quality

- Debug: allows us to add a `binding.break` break point to the code wherever needed.
- Rubocop: allows us to run a linter to ensure code quality.

## 🚂 Features

- Scrapes all colleges from the College Board website and stores them in `colleges` table
- Fetches total number of colleges from the primary page (script can handle changing source datasets)
- Idempotent (running the script again won't re-write the same data)
- Progress Bar: see real time progress of the scrape
- Throttling: randomly throttles the requests to the College Board website to avoid getting flagged as a bot
- Retry Mechanism: retries the college code scrape if it fails
- Dry Run: see the scrape real time, without writing to the database
- Optimizations: Configured selenium and capybara to run headless, increase wait and timeout times, and restart browser session every 100 colleges to free up memory.
- **TODO:**
  - Error Handling
  - Logging

## 🐞 Debugging

- The `debug` gem is included in this project, and imported in the Rakefile, so is available to use throughout the project, as long as running the script via the Rake command.
- Add a `binding.break` to the code to add a break point.

## 🤔 Technical Concerns

// TODO: Add technical concerns

## 🏃‍♂️ Improvements

- Add automated testing suite to repository that runs on CI/CD pipeline
- Add a frontend to the application to allow users to search for colleges by name, city, state, etc.
- Add a public API to allow users to search for colleges by name, city, state, etc.

## 🙏 Thank You Note

// TODO: Add thank you note
