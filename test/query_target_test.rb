require 'minitest/autorun'

require 'roaster/query'

require_relative 'test_helper'

class QueryTargetTest < MiniTest::Unit::TestCase

  def setup
    super
  end

  def test_defaults
    target = Roaster::Query::Target.new(:albums)
    assert_equal target.resource_name, :albums
    assert_equal target.resource_ids, []
    assert_equal target.relationship_name, nil
    assert_equal target.relationship_ids, []
  end

  def test_init
    target = Roaster::Query::Target.new(:albums, 1, :tracks, [2, 3])
    assert_equal target.resource_name, :albums
    assert_equal target.resource_ids, [1]
    assert_equal target.relationship_name, :tracks
    assert_equal target.relationship_ids, [2, 3]
  end

end
