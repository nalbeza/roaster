require 'roaster/decorator'

class AlbumMapping < Roaster::Decorator

  include Representable::Hash

  property :title
  #property :created_at

  # TODO: auto include included mapping
  # Aiming: Nested sparse fieldsets authorizations and default behaviour for sort
  can_include :band, :tracks

  can_filter_by :band, :title

  can_sort_by :band, :title, :created_at, band: [:name]

  collection_representer class: Album
end
