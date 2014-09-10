require 'minitest/autorun'

require 'roaster/query'
require 'roaster/adapters/active_record'

require_relative 'models/album'
require_relative 'test_helper'

class ActiveRecordAdapterTest < MiniTest::Unit::TestCase

  def test_read
    adapter = Roaster::Adapters::ActiveRecord.new(Album)
    target = Roaster::Query::Target.new
    mapping = AlbumMapping
    params = {
    }
    query = Roaster::Query.new(mapping, target, params)
    ar_query = adapter.read(query)
  end

end
