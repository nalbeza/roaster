require_relative 'support/active_record'
require 'database_cleaner'
require 'awesome_print'

#DatabaseCleaner.strategy = :truncation
DatabaseCleaner.strategy = :transaction

class MiniTest::Unit::TestCase
  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end
end
