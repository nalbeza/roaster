require 'roaster/json_api'

class TrackMapping < Roaster::JsonApi::Mapping

  property :title
  has_one :album

end
