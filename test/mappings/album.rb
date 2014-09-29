require 'roaster/json_api'

class AlbumMapping < Roaster::JsonApi::Mapping

  property :title

  has_many :tracks
  has_many :bonus_tracks, mapping: :track
  has_one :band

  # TODO: auto include included mapping
  # Aiming: Nested sparse fieldsets authorizations and default behaviour for sort
  can_include :band, :tracks

  can_filter_by :band, :title

  can_sort_by :band, :title, :created_at, band: [:name]

end
