require 'roaster/decorator'
require 'representable/json'

module Roaster
  module JsonApi
    class Mapping < ::Roaster::Decorator
      include Representable::Hash
      def to_hash(options={})
        super options
      end
    end
  end
end
