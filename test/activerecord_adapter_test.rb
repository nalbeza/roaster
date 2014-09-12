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
    @mapping = AlbumMapping
  end

  def test_interface
    assert @adapter.respond_to?(:create)
    assert @adapter.respond_to?(:read)
    assert @adapter.respond_to?(:update)
    assert @adapter.respond_to?(:delete)
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

  def test_create
    q = call_adapter_method :create
    assert q.to_sql == 'toto'
  end

  def test_read
    q = call_adapter_method :read
  end

  def test_update
    q = call_adapter_method :update
  end

  def test_delete
    q = call_adapter_method :delete
  end

  private

  def call_adapter_method(method,
                          target = Roaster::Query::Target.new,
                          params = {})
    query = Roaster::Query.new(target, @mapping, params)
    @adapter.send(method, query)
  end
=end

end
