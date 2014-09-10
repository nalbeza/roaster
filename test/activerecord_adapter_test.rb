require 'minitest/autorun'

require 'roaster/query'
require 'roaster/adapters/active_record'

require_relative 'models/album'
require_relative 'test_helper'

class ActiveRecordAdapterTest < MiniTest::Unit::TestCase

  def setup
    super
    @album_adapter = Roaster::Adapters::ActiveRecord.new(Album)
    @mapping = AlbumMapping
  end

  def test_create
    q = call_adapter_method :create
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
    @album_adapter.send(method, query)
  end

end
