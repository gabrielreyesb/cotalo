source "https://rubygems.org"

ruby "3.3.0"

gem 'rails', '7.1.5' 
gem "sprockets-rails"
gem "sqlite3", "~> 1.4"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "redis", ">= 4.0.1"
gem "bootsnap", require: false
gem "sassc", "~> 2.4"
gem 'devise'
gem 'prawn'
gem 'prawn-table'

# Add these gems
gem 'sass-rails'
gem 'sassc-rails'

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
  gem 'dotenv-rails'
end

group :development do
  gem "web-console"
end

group :production do
  gem 'pg'
end
group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
