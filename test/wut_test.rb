require 'minitest/autorun'

require 'roaster/query'
require 'roaster/resource'
require 'roaster/request'

require_relative 'test_helper'

class QueryTest < MiniTest::Test

  def test_ponies
    params = {}
    target = Roaster::Query::Target.new(:albums)
    resource = Roaster::Resource.new(target,
                                     adapter_class: Roaster::Adapters::ActiveRecord)
                                     #model_class: ::Blog::Category
    rq = Roaster::Request.new(:read,
                              resource,
                              params)
                              #input_resource: nil,
                              #mapping_class: AlbumMapping
    res = rq.execute
    puts '========== RES ==========='
    ap res
    puts '=========================='
  end

end
