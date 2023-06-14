# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

# psq-texting-service
An API that accepts a text message from a client, and sends that text message to SMS providers.

## Setup
### Prerequisites
This is a Ruby on Rails API application with a PostgreSQL database. If you already have Ruby 3.2 and PostgreSQL 14 installed, you can safely skip this section. I'm using homebrew on a Macbook, and the setup instructions are going to relfect that, but if that's not the system you're using you can still follow along. You may need to look up commands that are appropriate for your system if that's the case.
1. Get [homebrew](https://brew.sh/)
You can check homebrew's site for the latest instructions, but here's what I used:
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
2. Installing Ruby
I used [rbenv](https://github.com/rbenv/rbenv) to install Ruby. Quick steps:
```
brew install rbenv ruby-build
rbenv init
# follow instructions provided by the output of rbenv init
rbenv install 3.2.2
gem install bundler
```
3. Installing PostgreSQL
You may have to tap the postgresql cask in order to get this to work. The output of the first command should let you know if that's something you need to do.
```
brew install postgresql@14
brew services start postgresql
createuser -P -d psq_texting_service
# enter your password, and remember it for your config/database.yml file
```

### Running the app
1. Clone the repository
2. Add a file called `.env` in the root of the project. Add your PostgreSQL password to it:
```
PSQL_PASSWORD: <your password>
```
3. Set up the development and test databases:
```
bin/rails db:create
```
3. Install gems
```
bundle
```
4. Run rails!
```
bin/rails s
```
