Webrat.configure do |config|
  config.mode = :selenium
end

Cucumber::Rails::World.use_transactional_fixtures = false

require 'database_cleaner'
require 'database_cleaner/cucumber'

DatabaseCleaner.clean_with :truncation
DatabaseCleaner.strategy = :truncation

Before do
  Fixtures.reset_cache
  fixtures_folder = File.join(RAILS_ROOT, 'test', 'fixtures')
  fixtures = ['environments', 'roles']
  Fixtures.create_fixtures(fixtures_folder, fixtures)
  ENV['LANG'] = 'C'
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end