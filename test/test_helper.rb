require_relative 'support/active_record'
require 'database_cleaner'
require 'awesome_print'
require 'factory_girl'
require 'byebug'

#DatabaseCleaner.strategy = :truncation
DatabaseCleaner.strategy = :transaction

class MiniTest::Test
  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end
end
