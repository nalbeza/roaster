require 'roaster/json_api'

class AliasedAlbumMapping < Roaster::JsonApi::Mapping

  property :title, as: :name

  has_many :tracks, as: :songs
  has_one :band, as: :artist

  # TODO: auto include included mapping
  # Aiming: Nested sparse fieldsets authorizations and default behaviour for sort
  can_include :band, :tracks

  can_filter_by :band, :title

  can_sort_by :band, :title, :created_at, band: [:name]

end
