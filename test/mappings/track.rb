require 'roaster/json_api'

class TrackMapping < Roaster::JsonApi::Mapping

  property :title
  has_one :album
  has_one :album_as_bonus, mapping: :album
end
