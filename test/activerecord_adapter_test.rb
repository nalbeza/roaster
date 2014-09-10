require 'minitest/autorun'

require 'roaster/query'
require 'roaster/adapters/active_record'

require_relative 'models/album'

class ClientTest < MiniTest::Unit::TestCase

  def test_read
    adapter = Roaster::Adapters::ActiveRecord.new(Album)
    target = Target.new
    mapping = AlbumMapping
    query = Query.new()
    ar_query = adapter.read(query)
  end

end
