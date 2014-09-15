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

  def test_simple_sorting
    q = build_query({ sort: '-title,created_at' })
    assert_equal({title: :desc, created_at: :asc}, q.sorting)
  end

  def test_nested_sorting
    q = build_query({ sort: {
      band: 'name',
      albums: '-created_at,title'
    }})
    assert_equal({
      band: {
        name: :desc
      },
      albums: {
        created_at: :desc,
        title: :asc
      }
    }, q.sorting)
  end

  private

  def build_query(params = {})
    Roaster::Query.new(:read, @target, @mapping, params)
  end

end
