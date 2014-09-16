require 'minitest/autorun'

require 'roaster/query'
require 'roaster/adapters/active_record'

require_relative 'test_helper'
require_relative 'models/album'
#require_relative 'models/namespaced/model'

class ActiveRecordAdapterTest < MiniTest::Test

  def setup
    super
    @adapter = Roaster::Adapters::ActiveRecord.new
    @album_mapping = AlbumMapping
    @albums_target = Roaster::Query::Target.new(:albums)
  end

  def test_interface
    assert @adapter.respond_to?(:new)
    assert @adapter.respond_to?(:save)
    assert @adapter.respond_to?(:find)
    assert @adapter.respond_to?(:read)
    assert @adapter.respond_to?(:delete)
  end

  def test_mapping_class_from_resource_name
    mc = Roaster::Adapters::ActiveRecord.model_class_from_resource_name(:albums)
    assert_equal Album, mc
  end

  def test_simple_model_for
    model = @adapter.send(:model_for, :albums)
    assert_equal model, Album
  end

  def test_custom_model_for
    model = @adapter.send(:model_for, Album)
    assert_equal model, Album
  end

  def test_new
    query = build_query(:create)
    model_instance = @adapter.new(query)
    assert_kind_of Album, model_instance
  end

  def test_save
    title = 'Serial Smokers'
    query = build_query(:create)
    model_instance = @adapter.new(query)
    model_instance.send(:title=, title)
    @adapter.save(model_instance)

    new_album = Album.last
    assert_equal model_instance, new_album
    assert_equal title, new_album.title
  end

  def test_find
    ref_album = FactoryGirl.create(:album)
    target = Roaster::Query::Target.new(:albums, ref_album.id)
    #TODO: API problems (why do i need a full query here ?!)!
    query = build_query(:update, target)
    album = @adapter.find(query)

    assert_equal album, ref_album
  end

  private

  def call_adapter_method(method,
                          target,
                          params = {})
    query = Roaster::Query.new(method, target, @mapping, params)
    @adapter.send(method, query)
  end

  def build_query(operation, target = @albums_target, mapping = @album_mapping, params = {})
    Roaster::Query.new(:create, @albums_target, @album_mapping, params)
  end

  def test_new
    query = build_query(:create)
    model_instance = @adapter.new(query)
    assert_kind_of Album, model_instance
  end

  def test_save
    title = 'Serial Smokers'
    query = build_query(:create)
    model_instance = @adapter.new(query)
    model_instance.send(:title=, title)
    @adapter.save(model_instance)

    new_album = Album.last
    assert_equal model_instance, new_album
    assert_equal title, new_album.title
  end

  def test_find
    ref_album = FactoryGirl.create(:album)
    target = Roaster::Query::Target.new(:albums, ref_album.id)
    #TODO: API problems (why do i need a full query here ?!)!
    query = build_query(:update, target)
    album = @adapter.find(query)

    assert_equal album, ref_album
  end

  private

  def call_adapter_method(method,
                          target,
                          params = {})
    query = Roaster::Query.new(method, target, @mapping, params)
    @adapter.send(method, query)
  end

  def build_query(operation, target = @albums_target, mapping = @album_mapping, params = {})
    Roaster::Query.new(:create, @albums_target, @album_mapping, params)
  end

end
