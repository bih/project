source 'https://rubygems.org'

# Rails core.
gem 'rails', '4.2.0.rc3'

# DEVELOPMENT
group :development, :test do
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'

  # Call 'debugger' anywhere in the code to stop execution and get a debugger console
  gem 'debugger'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

# PRODUCTION
group :production do
  # Use postgresql as the database for Active Record
  gem 'pg'
  
  # Fixes Heroku bug.
  gem 'rails_12factor'
end

# ALL ENVIRONMENTS
group :production, :development, :test do
  # Use ActiveModel has_secure_password
  gem 'bcrypt', '~> 3.1.7'

  # A flexible authentication system.
  gem "devise"

  # Fake data.
  gem "faker"

  # Import and export data.
  gem 'yaml_db'

  # Beautiful templating.
  gem 'haml-rails'

  # Beautiful forms.
  gem 'simple_form'

  # Email validation.
  gem 'email_validator'

  # Logging all actions.
  gem "audited-activerecord", "~> 4.0"

  # Pagination.
  gem 'will_paginate', '~> 3.0.6'
  gem 'will_paginate-bootstrap'

  # Twitter Bootstrap.
  gem "therubyracer"
  gem "less-rails"
  gem 'twitter-bootstrap-rails', :git => 'git://github.com/seyhunak/twitter-bootstrap-rails.git'

  # Beautiful progress bars.
  gem "ladda-rails"

  # Moment.js
  gem "momentjs-rails"

  # Google Charts.
  gem "googlecharts"
end

# ASSETS
group :production, :development, :test do
  # Use SCSS for stylesheets
  gem 'sass-rails', '~> 5.0'

  # Use Uglifier as compressor for JavaScript assets
  gem 'uglifier', '>= 1.3.0'

  # Use jquery as the JavaScript library
  gem 'jquery-rails'

  # Use CoffeeScript for .coffee assets and views
  gem 'coffee-rails', '~> 4.1.0'

  # jQuery DateTime picker.
  gem 'jquery-datetimepicker-rails'

  # Select2.
  gem 'select2-rails'
end

# DOCUMENTATION
group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', '~> 0.4.0'
end