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

  def test_ponies
    params = {}
    target = Roaster::Query::Target.new(:albums)
    rq = Roaster::Request.new(:read,
                              target,
                              @ar_resource,
                              params)
    res = rq.execute
    assert_equal([{"title" => "Animals"}, {"title" => "The Wall"}, {"title" => "Meddle"}], res)
  end

  def test_sorted_ponies
    params = {sort: :title}
    target = Roaster::Query::Target.new(:albums)
    rq = Roaster::Request.new(:read,
                              target,
                              @ar_resource,
                              params)
    res = rq.execute
    assert_equal([{"title" => "Animals"}, {"title" => "Meddle"}, {"title" => "The Wall"}], res)
  end

  def test_create_pony
    params = {}
    target = Roaster::Query::Target.new(:albums)
    album_hash = {
      'title' => 'The Downward Spiral'
    }
    rq = Roaster::Request.new(:create,
                              target,
                              @ar_resource,
                              params,
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
    target = Roaster::Query::Target.new(:albums, album.id)
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
    target = Roaster::Query::Target.new(:albums, album_id)
    rq = Roaster::Request.new(:delete,
                              target,
                              @ar_resource,
                              {})

    res = rq.execute
    refute Album.exists?(album_id)
  end

end
