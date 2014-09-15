require 'minitest/autorun'

require 'roaster/query'
require 'roaster/resource'
require 'roaster/request'

require_relative 'test_helper'
require_relative 'factories/album'

class PoniesTest < MiniTest::Test

  def setup
    super
    FactoryGirl.create(:animals_album)
    FactoryGirl.create(:the_wall_album)
    FactoryGirl.create(:meddle_album)
  end

  def test_ponies
    params = {}
    target = Roaster::Query::Target.new(:albums)
    resource = Roaster::Resource.new(Roaster::Adapters::ActiveRecord)
                              #model_class: ::Blog::Category
    rq = Roaster::Request.new(:read,
                              target,
                              resource,
                              params)
                              #input_resource: nil,
                              #mapping_class: AlbumMapping
    res = rq.execute
    assert_equal([{"title" => "Animals"}, {"title" => "The Wall"}, {"title" => "Meddle"}], res)
  end

  def test_sorted_ponies
    params = {sort: :title}
    target = Roaster::Query::Target.new(:albums)
    resource = Roaster::Resource.new(Roaster::Adapters::ActiveRecord)
                              #model_class: ::Blog::Category
    rq = Roaster::Request.new(:read,
                              target,
                              resource,
                              params)
                              #input_resource: nil,
                              #mapping_class: AlbumMapping
    res = rq.execute
    assert_equal([{"title" => "Animals"}, {"title" => "Meddle"}, {"title" => "The Wall"}], res)
  end

end
