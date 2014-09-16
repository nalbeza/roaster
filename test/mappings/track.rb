require 'roaster/decorator'

class TrackMapping < Roaster::Decorator

  include Representable::Hash

  property :title

end
 
