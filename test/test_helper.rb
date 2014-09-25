require 'roaster'
require 'database_cleaner'
require 'awesome_print'
require 'factory_girl'
require 'byebug'
require 'json_expressions/minitest'

require_relative 'support/active_record'
require_relative 'models/album'
require_relative 'models/band'
require_relative 'models/track'

#TODO: Autoload those somehow
require_relative 'mappings/album'
require_relative 'mappings/aliased_album'
require_relative 'mappings/band'
require_relative 'mappings/track'


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
