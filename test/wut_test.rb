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

  def test_create_pony
    params = {}
    target = Roaster::Query::Target.new(:albums)
    resource = Roaster::Resource.new(Roaster::Adapters::ActiveRecord)
    album_hash = {
      'title' => 'The Downward Spiral'
    }
    rq = Roaster::Request.new(:create,
                              target,
                              resource,
                              params,
                              document: album_hash)
                              #input_resource: nil,
                              #mapping_class: AlbumMapping

    res = rq.execute
    refute_nil res.id
    assert_equal 'The Downward Spiral', res.title
  end

  def test_update_pony
    album = FactoryGirl.create(:album)
    album_update_hash = {
      'title' => 'Antichrist Superstar'
    }
    target = Roaster::Query::Target.new(:albums, album.id)
    resource = Roaster::Resource.new(Roaster::Adapters::ActiveRecord)
    rq = Roaster::Request.new(:update,
                              target,
                              resource,
                              {},
                              document: album_update_hash)

    res = rq.execute
    assert_equal album.id, res.id
    assert_equal 'Antichrist Superstar', res.title
  end

  def test_delete_pony
    album = FactoryGirl.create(:album)
    album_id = album.id
    target = Roaster::Query::Target.new(:albums, album_id)
    resource = Roaster::Resource.new(Roaster::Adapters::ActiveRecord)
    rq = Roaster::Request.new(:delete,
                              target,
                              resource,
                              {})

    res = rq.execute
    refute Album.exists?(album_id)
  end

end
