require 'minitest/autorun'

require 'roaster/query'
require 'roaster/adapters/active_record'

require_relative 'models/album'
require_relative 'test_helper'

class ActiveRecordAdapterTest < MiniTest::Unit::TestCase

  private
  def call_adapter_method(method)
    target = Roaster::Query::Target.new
    mapping = AlbumMapping
    params = {
    }
    query = Roaster::Query.new(target, mapping, params)
    ar_query = @album_adapter.send(method, query)
  end

  public

  def setup
    super
    @album_adapter = Roaster::Adapters::ActiveRecord.new(Album)
  end

  def test_create
    call_adapter_method :create
  end

  def test_read
    call_adapter_method :read
  end

  def test_update
    call_adapter_method :update
  end


  def test_delete
    call_adapter_method :delete
  end

end
