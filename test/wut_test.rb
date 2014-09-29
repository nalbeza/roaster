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
    FactoryGirl.create(:animals_album, band: nil)
    FactoryGirl.create(:the_wall_album, band: nil)
    FactoryGirl.create(:meddle_album, band: nil)

    @arch_enemy_band = FactoryGirl.create :band, name: 'Arch Enemy'
    @wages_of_sin_album = FactoryGirl.create :album, title: 'Wages of Sin', band: @arch_enemy_band, tracks: [
      FactoryGirl.create(:track, title: 'Enemy Within'),
      FactoryGirl.create(:track, title: 'Burning Angel'),
      FactoryGirl.create(:track, title: 'Heart Of Darkness')
    ], bonus_tracks: [
      FactoryGirl.create(:track, title: 'mystery')
    ]
    @ar_resource = Roaster::Resource.new(Roaster::Adapters::ActiveRecord)
  end

  def build_target(resource_name = :albums, resource_ids = nil, relationship_name = nil, relationship_ids = nil)
    Roaster::Query::Target.new(resource_name, resource_ids, relationship_name, relationship_ids)
  end

  def build_request(operation, target: build_target, resource: @ar_resource, params: {}, document: nil, mapping_class: nil)
    Roaster::Request.new(operation,
                         target,
                         resource,
                         params,
                         document: document,
                         mapping_class: mapping_class)
  end

  def test_single
    target = build_target(:albums, @wages_of_sin_album.id.to_s)
    rq = build_request(:read, target: target)
    res = rq.execute
    assert_equal({
      'albums' => {
        'id' => @wages_of_sin_album.id.to_s,
        'links' => {
          'band' => {
            'id' => @wages_of_sin_album.band_id.to_s,
            'type' => 'bands'
            },
          'tracks' => {
            'ids' => @wages_of_sin_album.tracks.map(&:id).map(&:to_s),
            'type' => 'tracks'
            },
          'bonus_tracks'=> {
            'ids'=> @wages_of_sin_album.bonus_tracks.map(&:id).map(&:to_s),
            'type'=>'tracks'
          }
        },
        'title' => @wages_of_sin_album.title}
    }, res)
  end

  def test_aliases
    target = build_target(:albums, @wages_of_sin_album.id.to_s)
    rq = build_request(:read, target: target, mapping_class: AliasedAlbumMapping)
    res = rq.execute
    assert_equal({
      'aliased_albums' => {
        'id' => @wages_of_sin_album.id.to_s,
        'links' => {
          'artist' => {
            'id' => @wages_of_sin_album.band_id.to_s,
            'type' => 'bands'
          },
          'songs' => {
            'ids' => @wages_of_sin_album.tracks.map(&:id).map(&:to_s),
            'type' => 'tracks'
          }
        },
        'name' => @wages_of_sin_album.title}
    }, res)
  end

  def test_ponies
    rq = build_request(:read)
    res = rq.execute
    assert_equal({'albums' => [
      {'id' => '1', 'links'=>{'band' => { 'type' => 'bands', 'id' => nil}, 'tracks' => { 'type' => 'tracks', 'ids' => []},'bonus_tracks'=>{'ids'=>[], 'type'=>'tracks'}  }, 'title' => 'Animals'},
      {'id' => '2', 'links'=>{'band' => { 'type' => 'bands', 'id' => nil}, 'tracks' => { 'type' => 'tracks', 'ids' => []},'bonus_tracks'=>{'ids'=>[], 'type'=>'tracks'}  }, 'title' => 'The Wall'},
      {'id' => '3', 'links'=>{'band' => { 'type' => 'bands', 'id' => nil}, 'tracks' => { 'type' => 'tracks', 'ids' => []},'bonus_tracks'=>{'ids'=>[], 'type'=>'tracks'}  }, 'title' => 'Meddle'},
      {'id' => '4', 'links'=>{'band' => { 'type' => 'bands', 'id' => @wages_of_sin_album.band_id.to_s }, 'tracks'=>{ 'type' => 'tracks', 'ids' => ['1', '2', '3']}, 'bonus_tracks'=>{'ids'=>['4'], 'type'=>'tracks'} }, 'title' => 'Wages of Sin'}]},
      res)
  end

   def test_sorted_ponies
    params = {sort: :title}
    rq = build_request(:read, params: params)
    res = rq.execute
    assert_equal({'albums' => [
        {'id' => '1', 'links'=>{'band' => { 'type' => 'bands', 'id' => nil}, 'tracks' => { 'type' => 'tracks', 'ids' => []},'bonus_tracks'=>{'ids'=>[], 'type'=>'tracks'} }, 'title' => 'Animals'},
        {'id' => '3', 'links'=>{'band' => { 'type' => 'bands', 'id' => nil}, 'tracks' => { 'type' => 'tracks', 'ids' => []},'bonus_tracks'=>{'ids'=>[], 'type'=>'tracks'} }, 'title' => 'Meddle'},
        {'id' => '2', 'links'=>{'band' => { 'type' => 'bands', 'id' => nil}, 'tracks' => { 'type' => 'tracks', 'ids' => []},'bonus_tracks'=>{'ids'=>[], 'type'=>'tracks'} }, 'title' => 'The Wall'},
        {'id' => '4', 'links'=>{'band' => { 'type' => 'bands', 'id' => @wages_of_sin_album.band_id.to_s }, 'tracks'=>{ 'type' => 'tracks', 'ids' => ['1', '2', '3']}, 'bonus_tracks'=>{'ids'=>['4'], 'type'=>'tracks'} }, 'title' => 'Wages of Sin'}]},
      res)
  end

  def test_simple_filtered_ponies
    params = {title: 'Animals'}
    rq = build_request(:read, params: params)
    res = rq.execute
    assert_equal({'albums' => [{'id' => '1',
      'links' => {
        'band' => {
          'id' => nil,
          'type' => 'bands'
          },
        'tracks' => {
          'ids'=>[],
          'type'=>'tracks'
          },
        'bonus_tracks' => {
          'ids'=>[],
          'type'=>'tracks'
          }
        },
      'title' => 'Animals'}]}, res)
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
    target = build_target(:albums, @wages_of_sin_album.id.to_s, :band)
    rq = build_request(:read, target: target)
    res = rq.execute
    assert_equal({'bands' => {'id' => @wages_of_sin_album.band_id.to_s, 'name' => 'Arch Enemy'}}, res)
  end

  def test_read_to_many_relationship
    target = build_target(:albums, @wages_of_sin_album.id.to_s, :tracks)
    rq = build_request(:read, target: target)
    # byebug
    res = rq.execute
    assert_equal({
      'tracks'=> [
        {
          'id'=>'1',
          'title' => 'Enemy Within',
          'links' => {
            'album' => {
              'id' => @wages_of_sin_album.id.to_s,
              'type' => 'albums'
              },
            'album_as_bonus' => {
              'id' => nil,
              'type' => 'albums'
            }
          }
        },
        {
          'id'=>'2',
          'title' => 'Burning Angel',
          'links' => {
            'album' => {
              'id' => @wages_of_sin_album.id.to_s,
              'type' => 'albums'
              },
            'album_as_bonus' => {
              'id' => nil,
              'type' => 'albums'
            }
          }
        },
        {
          'id'=>'3',
          'title' => 'Heart Of Darkness',
          'links' => {
            'album' => {
              'id' => @wages_of_sin_album.id.to_s,
              'type' => 'albums'
              },
            'album_as_bonus' => {
              'id' => nil,
              'type' => 'albums'
            }
          }
        }
      ]
    }, res)
  end

  def test_create_pony
    album_hash = {
      'albums' => {
        'title' => 'The Downward Spiral'
      }
    }
    rq = build_request(:create, document: album_hash)

    res = rq.execute
    refute_nil res['albums']
    refute_nil res['albums']['id']
    assert_equal 'The Downward Spiral', res['albums']['title']
  end

  def test_create_aliased
    song = FactoryGirl.create(:track)
    artist = FactoryGirl.create(:band)
    album_hash = {
      'aliased_albums' => {
        'name' => 'The Downward Spiral',
        'links' => {
          'songs' => [song.id.to_s],
          'artist' => artist.id.to_s
        }
      }
    }
    rq = build_request(:create, document: album_hash, mapping_class: AliasedAlbumMapping)

    res = rq.execute
    refute_nil res['aliased_albums']
    refute_nil res['aliased_albums']['id']
    assert_equal song.id.to_s, res['aliased_albums']['links']['songs']['ids'].first
    assert_equal artist.id.to_s, res['aliased_albums']['links']['artist']['id']
    assert_equal 'The Downward Spiral', res['aliased_albums']['name']
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
    assert_equal 3, album.tracks.count
    assert_equal Set.new(album.tracks.map(&:id)), Set.new([track_1, track_3, track_4].map(&:id))
  end

  def test_update_pony
    album = FactoryGirl.create(:album)
    album_update_hash = {
      'albums' => {
        'title' => 'Antichrist Superstar'
      }
    }
    target = build_target(:albums, album.id)
    rq = build_request(:update, target: target, document: album_update_hash)

    res = rq.execute
    assert_equal album.id.to_s, res['albums']['id']
    assert_equal 'Antichrist Superstar', res['albums']['title']
  end

  def test_update_to_one_relationship
    album = FactoryGirl.create(:album, title: 'Killing Is My Business... and Business Is Good!')
    band = FactoryGirl.create(:band, name: 'Megadeth')
    album_update_hash = {
      'links' => {
        'band' => band.id.to_s
      }
    }
    target = build_target(:albums, album.id)
    rq = build_request(:update, target: target, document: album_update_hash)

    res = rq.execute
    album.reload
    assert_nil res
    assert_equal 'Megadeth', album.band.name
  end

  def test_read_has_one_links
    album = FactoryGirl.create :album, title: 'Ride the Lightning'
    track = FactoryGirl.create :track, title: 'Fight Fire With Fire', album: album
    target = build_target(:track, track)
    rq = build_request(:read, target: target)
    res = rq.execute
    assert_json_match({
      tracks: {
        id: track.id.to_s,
        links: {
          album: {
            id: album.id.to_s,
            type: 'albums'
            },
          album_as_bonus: {
            id: nil,
            type: 'albums'
          }
        },
        title: 'Fight Fire With Fire',
      }}, res)
  end


  def test_create_with_has_one_links
    album = FactoryGirl.create :album, title: 'Ride the Lightning'
    track_hash = {
      'tracks' => {
        'title' => 'Fight Fire With Fire',
        'links' => {
          'album' => album.id.to_s
        }
      }
    }
    target = build_target(:tracks)
    rq = build_request(:create, target: target, document: track_hash)
    res = rq.execute
    # byebug
    assert_json_match({
      tracks: {
        id: '5',
        links: {
          album: {
            'id' => album.id.to_s,
            'type' => 'albums'
          },
          'album_as_bonus' => {
            'id' => nil,
            'type' => 'albums'
          }
        },
        title: 'Fight Fire With Fire',
      }}, res)
  end

  def test_read_has_many_links
    # byebug
    track_1 = FactoryGirl.create :track, title: 'Fight Fire With Fire'
    # Track 2 omitted because it has the same title as the album
    track_3 = FactoryGirl.create :track, title: 'For Whom The Bell Tolls'
    track_4 = FactoryGirl.create :track, title: 'Fade to Black'
    album = FactoryGirl.create :album, title: 'Ride the Lightning', tracks: [track_1, track_3, track_4]
    target = build_target(:album, album.id.to_s)
    rq = build_request(:read, target: target)
    res = rq.execute
    assert_json_match({
      albums: {
        id: '5',
        links: {
          tracks: {
            ids: [track_1.id.to_s, track_3.id.to_s, track_4.id.to_s],
            type: 'tracks'
            },
          band: {
            id: album.band_id.to_s,
            type: 'bands'
            },
          bonus_tracks: {
            ids: [],
            type: 'tracks'
          }
        },
        title: 'Ride the Lightning',
      }}, res)
  end

  def test_update_to_many_relationship
    track_1 = FactoryGirl.create :track, title: 'Fight Fire With Fire'
    # Track 2 omitted because it has the same title as the album
    track_3 = FactoryGirl.create :track, title: 'For Whom The Bell Tolls'
    track_4 = FactoryGirl.create :track, title: 'Fade to Black'
    album = FactoryGirl.create :album, title: 'Ride the Lightning', tracks: [track_1]

    document = {
      'links' => {
        'tracks' => [track_3.id.to_s, track_4.id.to_s]
      }
    }
    target = build_target(:albums, album.id, :tracks)
    rq = build_request(:update, target: target, document: document)

    res = rq.execute
    album.reload
    assert_nil res
    assert_equal 2, album.tracks.count
    assert_equal Set.new(album.tracks.map(&:id)), Set.new([track_3, track_4].map(&:id))
  end

  def test_delete_pony
    album = FactoryGirl.create(:album)
    album_id = album.id
    target = build_target(:albums, album_id)
    rq = build_request(:delete)

    res = rq.execute
    refute Album.exists?(album_id)
  end

  def test_invalid_single_id
    target = build_target(:albums, SecureRandom.hex)
    rq = build_request(:read, target: target)
    assert_raises(Roaster::ResourceNotFoundError) { rq.execute }
  end

end
