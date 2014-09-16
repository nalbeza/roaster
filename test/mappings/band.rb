require 'roaster/decorator'

class BandMapping < Roaster::Decorator
  include Representable::Hash

  property :name
end
