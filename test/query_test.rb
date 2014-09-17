require 'minitest/autorun'

require 'roaster/query'

require_relative 'test_helper'

class QueryTest < MiniTest::Test

  def setup
    super
    @target = Roaster::Query::Target.new(:albums)
    @mapping = AlbumMapping
  end

  def test_page_defaults
    q = build_query()
    assert_equal 1, q.page
    assert_equal Roaster::Query::DEFAULT_PAGE_SIZE, q.page_size
    assert_equal [], q.includes
    assert_equal Hash.new, q.filters
    assert_equal Hash.new, q.sorting
  end

  def test_includes
    q = build_query({ include: 'band,tracks' })
    assert_equal [:band, :tracks], q.includes
  end

  def test_filters
    q = build_query({ band: 1 })
    assert_equal({band: 1}, q.filters)
  end

  # TODO: Make this one pass !
  # def test_nested_filters
  #   q = build_query({
  #     fields: {
  #       band: {
  #         name: 'Pink Floyd'
  #       },
  #       albums: {
  #         title: 'Animals'
  #       }
  #     }
  #   })
  #   assert_equal({
  #     band: {
  #       name: 'Pink Floyd'
  #     },
  #     albums: {
  #       title: 'Animals'
  #     }
  #   }, q.filters)
  # end

  def test_simple_sorting
    q = build_query({ sort: '-title,created_at' })
    assert_equal({title: :desc, created_at: :asc}, q.sorting)
  end

  def test_typed_sorting
    q = build_query({ sort: {
      band: 'name',
      albums: '-created_at,title'
    }})
    assert_equal({
      band: {
        name: :asc
      },
      albums: {
        created_at: :desc,
        title: :asc
      }
    }, q.sorting)
  end

  def test_sparse_fieldsets
    q = build_query({ fields: 'title' })
    assert_equal({albums: [:title]}, q.fields)
  end

  # TODO: Make this one pass !
  # def test_typed_sparse_fieldsets
  #   q = build_query({ fields: {
  #     'band': 'name',
  #     'albums': 'title'}
  #   })
  #   assert_equal({feilds: 'title'}, q.filters)
  # end

  private

  def build_query(params = {})
    Roaster::Query.new(:read, @target, @mapping, params)
  end

end
