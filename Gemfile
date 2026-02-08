source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in event_engine.gemspec.
gemspec

group :development, :test do
  # Needed for the dummy app database
  gem "sqlite3"
  gem "sprockets-rails"
  gem "pry"
  gem "pry-byebug"
  gem "minitest-reporters"
  gem "minitest-focus"
  gem "diffy"
  gem "webmock"
end


# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"
