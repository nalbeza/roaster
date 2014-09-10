require 'minitest/autorun'

require 'roaster/query'
require 'roaster/adapters/active_record'

require_relative 'models/album'
require_relative 'test_helper'

class ActiveRecordAdapterTest < MiniTest::Unit::TestCase

  def setup
    super
    @album_adapter = Roaster::Adapters::ActiveRecord.new(Album)
  end

  def test_read
    target = Roaster::Query::Target.new
    mapping = AlbumMapping
    params = {
    }
    query = Roaster::Query.new(target, mapping, params)
    ar_query = @album_adapter.read(query)
  end

end
