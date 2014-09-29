require 'minitest/autorun'

require 'roaster/request'

require_relative 'test_helper'
require_relative 'models/album'

class RequestTest < MiniTest::Test

  def test_mapping_class_from_target
    target = Roaster::Query::Target.new(:albums)
    mc = Roaster::Factory.mapping_class_from_target(target)
    assert_equal AlbumMapping, mc
  end

end
