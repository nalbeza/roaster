require 'minitest/autorun'

require 'roaster/request'

require_relative 'test_helper'
require_relative 'models/album'

class ResourceTest < MiniTest::Test

  def test_mapping_class_from_target
    target = Roaster::Query::Target.new(:albums)
    mc = Roaster::Resource.model_class_from_target(target)
    assert_equal Album, mc
  end

end
