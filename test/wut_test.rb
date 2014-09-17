require 'set'
require 'minitest/autorun'

require 'roaster/query'
require 'roaster/resource'
require 'roaster/request'

require_relative 'test_helper'
require_relative 'factories/album'
require_relative 'factories/track'
require_relative 'factories/band'

class PoniesTest < MiniTest::Test

  def setup
    super
    #TODO: Replace this by fixtures
    FactoryGirl.create(:animals_album)
    FactoryGirl.create(:the_wall_album)
    FactoryGirl.create(:meddle_album)
=begin
 1 - Enemy Within
 2 - Burning Angel
 3 - Heart Of Darkness
=end
    @arch_enemy_band = FactoryGirl.create :band, name: 'Arch Enemy'
    @wages_of_sin_album = FactoryGirl.create :album, title: 'Wages of Sin', band: @arch_enemy_band, tracks: [
      FactoryGirl.create(:track, title: 'Enemy Within'),
      FactoryGirl.create(:track, title: 'Burning Angel'),
      FactoryGirl.create(:track, title: 'Heart Of Darkness')
    ]
    @ar_resource = Roaster::Resource.new(Roaster::Adapters::ActiveRecord)
  end

  def build_target(resource_name = :albums, resource_ids = nil, relationship_name = nil, relationship_ids = nil)
    Roaster::Query::Target.new(resource_name, resource_ids, relationship_name, relationship_ids)
  end

  def build_request(operation, target: build_target, resource: @ar_resource, params: {}, document: nil)
    Roaster::Request.new(operation,
                         target,
                         resource,
                         params,
                         document: document)
  end

  def test_ponies
    rq = build_request(:read)
    res = rq.execute
    assert_equal([{'title' => 'Animals'}, {'title' => 'The Wall'}, {'title' => 'Meddle'}, {'title' => 'Wages of Sin'}], res)
  end

  # TODO: Make this one pass! See sorting part in active_record adapter read method
   def test_sorted_ponies
    return
    params = {sort: :title}
    rq = build_request(:read, params: params)
    res = rq.execute
    assert_equal([{'title' => 'Animals'}, {'title' => 'Meddle'}, {'title' => 'The Wall'}, {'title' => 'Wages of Sin'}], res)
  end

  def test_simple_filtered_ponies
    params = {title: 'Animals'}
    rq = build_request(:read, params: params)
    res = rq.execute
    assert_equal([{'title' => 'Animals'}], res)
  end

  #TODO: Make this one pass !
  #TODO: This is an extension, document it according to JSONAPI spec !
  def test_association_filtered_ponies
    return
    params = {
      band: {
        name: @arch_enemy_band.name
      }
    }
    rq = build_request(:read, params: params)
    res = rq.execute
    assert_equal 1, res.count
    assert_equal @arch_enemy_band.name, res.first.band.name
  end

  def test_read_to_one_relationship
    target = build_target(:albums, @wages_of_sin_album, :band)
    rq = build_request(:read, target: target)
    res = rq.execute
    assert_equal({'name' => 'Arch Enemy'}, res)
  end

  def test_read_to_many_relationship
    target = build_target(:albums, @wages_of_sin_album, :tracks)
    rq = build_request(:read, target: target)
    res = rq.execute
    assert_equal([{'title' => 'Enemy Within'}, {'title' => 'Burning Angel'}, {'title' => 'Heart Of Darkness'}], res)
  end

  def test_create_pony
    album_hash = {
      'title' => 'The Downward Spiral'
    }
    rq = build_request(:create, document: album_hash)

    res = rq.execute
    refute_nil res.id
    assert_equal 'The Downward Spiral', res.title
  end


  def test_update_to_one_relationship
    #TODO
  end

  def test_add_to_one_relationship
    album = FactoryGirl.create :album, title: 'Ride the Lightning'
    band = FactoryGirl.create :band, name: 'Metallica'

    document = {
      "bands" => band.id
    }
    target = build_target(:albums, album.id, :band)
    rq = build_request(:create, target: target, document: document)

    res = rq.execute
    album.reload
    assert_equal album.band.name, band.name
  end

  def test_update_to_many_relationship
    #TODO
  end

  def test_add_to_many_relationship
    track_1 = FactoryGirl.create :track, title: 'Fight Fire With Fire'
    # Track 2 omitted because it has the same title as the album
    track_3 = FactoryGirl.create :track, title: 'For Whom The Bell Tolls'
    track_4 = FactoryGirl.create :track, title: 'Fade to Black'
    album = FactoryGirl.create :album, title: 'Ride the Lightning', tracks: [track_1]

    document = {
      "tracks" => [track_3.id.to_s, track_4.id.to_s]
    }
    target = build_target(:albums, album.id, :tracks)
    rq = build_request(:create, target: target, document: document)

    res = rq.execute
    album.reload
    assert_equal album.tracks.count, 3
    assert_equal Set.new(album.tracks.map(&:id)), Set.new([track_1, track_3, track_4].map(&:id))
  end

  def test_update_pony
    album = FactoryGirl.create(:album)
    album_update_hash = {
      'title' => 'Antichrist Superstar'
    }
    target = build_target(:albums, album.id)
    rq = build_request(:update, target: target, document: album_update_hash)

    res = rq.execute
    assert_equal album.id, res.id
    assert_equal 'Antichrist Superstar', res.title
  end

  def test_delete_pony
    album = FactoryGirl.create(:album)
    album_id = album.id
    target = build_target(:albums, album_id)
    rq = build_request(:delete)

    res = rq.execute
    refute Album.exists?(album_id)
  end

end
