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
    @ar_resource = Roaster::Resource.new(Roaster::Adapters::ActiveRecord)
                              #model_class: ::Blog::Category
  end

  def build_target(resource_name = :albums, resource_ids = nil, relationship_name = nil, relationship_ids = nil)
    Roaster::Query::Target.new(resource_name, resource_ids, relationship_name, relationship_ids)
  end

  def test_ponies
    rq = Roaster::Request.new(:read,
                              build_target,
                              @ar_resource,
                              {})
    res = rq.execute
    assert_equal([{"title" => "Animals"}, {"title" => "The Wall"}, {"title" => "Meddle"}], res)
  end

  def test_sorted_ponies
    params = {sort: :title}
    rq = Roaster::Request.new(:read,
                              build_target,
                              @ar_resource,
                              params)
    res = rq.execute
    assert_equal([{"title" => "Animals"}, {"title" => "Meddle"}, {"title" => "The Wall"}], res)
  end

  def test_create_pony
    album_hash = {
      'title' => 'The Downward Spiral'
    }
    rq = Roaster::Request.new(:create,
                              build_target,
                              @ar_resource,
                              {},
                              document: album_hash)

    res = rq.execute
    refute_nil res.id
    assert_equal 'The Downward Spiral', res.title
  end

  def test_update_pony
    album = FactoryGirl.create(:album)
    album_update_hash = {
      'title' => 'Antichrist Superstar'
    }
    target = build_target(:albums, album.id)
    rq = Roaster::Request.new(:update,
                              target,
                              @ar_resource,
                              {},
                              document: album_update_hash)

    res = rq.execute
    assert_equal album.id, res.id
    assert_equal 'Antichrist Superstar', res.title
  end

  def test_delete_pony
    album = FactoryGirl.create(:album)
    album_id = album.id
    target = build_target(:albums, album_id)
    rq = Roaster::Request.new(:delete,
                              target,
                              @ar_resource,
                              {})

    res = rq.execute
    refute Album.exists?(album_id)
  end

end
