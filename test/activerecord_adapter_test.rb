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
    assert @adapter.respond_to?(:create)
    assert @adapter.respond_to?(:read)
    assert @adapter.respond_to?(:update)
    assert @adapter.respond_to?(:delete)
  end

  def test_mapping_class_from_resource_name
    mc = Roaster::Adapters::ActiveRecord.model_class_from_resource_name(:albums)
    assert_equal Album, mc
  end

=begin
  def test_simple_model_for_resource
    model = @adapter.send(:model_for, :albums)
    assert_equal model, Album
  end

=begin
  TODO: Make sure this is a good idea
  def test_namespace_model_for_resource
    model = @adapter.send(:model_for, :namespaced_models)
    assert_equal model, Namespaced::Model
  end
=end



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
    # band: 'Hugo Matha and The Crackheads'
    # {title: 'Serial Smokers'}
  end

=begin
  def test_read
    q = call_adapter_method :read
  end

  def test_update
    q = call_adapter_method :update
  end

  def test_delete
    q = call_adapter_method :delete
  end
=end

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
=begin
  /:resource
    - :create resource  

  /:resource/:id
    - :update attributes
    - :update to_one relationship
    - :update to_many relationship
    - :delete resource

  /:resource/:id/links/:rel
    - :create to_one relationship
    - :create to_many relationship
    - :read to_many relationship
    - :read to_one relationship
    - :delete to_one relationship

  /:resource/:id/links/:rel/:ids
    - :delete to_many relationship

=end
=begin

  def test_resource_for_all
    resource = @adapter.send(:resource_for, :albums)
    assert_equal resource, Album.all
  end

  def test_resource_for_id
    resource = @adapter.send(:resource_for, :albums, 1)
    assert_equal resource, Album.where(id: 1)
  end

  def test_scope_for_all
    target = Roaster::Query::Target.new(:albums)
    scope = @adapter.send(:scope_for, target)
    assert_equal scope, Album.all
  end

  def test_scope_for_id
    target = Roaster::Query::Target.new(:albums, 1)
    scope = @adapter.send(:scope_for, target)
    assert_equal scope, Album.where(id: 1)
  end

  def test_scope_for_ids
    target = Roaster::Query::Target.new([1, 2, 3])
    scope = @adapter.send(:scope_for, target)
    assert_equal scope, Album.where(id: [1, 2, 3])
  end

  def test_scope_for_relation
    target = Roaster::Query::Target.new([1, 2, 3])
    scope = @adapter.send(:scope_for, target)
    assert_equal scope, Album.where(id: [1, 2, 3])
  end
=end
end
