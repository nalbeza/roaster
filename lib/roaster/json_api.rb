require 'roaster/decorator'
require 'representable/json'

require 'representable/bindings/hash_bindings'

module Roaster
  module JsonApi

    class Binding < Representable::Hash::PropertyBinding
      alias_method :parent_serialize, :serialize

      def serialize(value)
        super
      end

      def serialize_collection(value)
        @mapping_class = @definition[:extend].instance_variable_get('@value')
        collection = value.collect { |item|
          parent_serialize(item)
        }
        { @mapping_class.get_resource_name => collection }
      end
    end

    class CollectionBinding < Binding
      def self.build_for(definition, *args)
        self.new(definition, *args)
      end

      def serialize(value)
        serialize_collection(value)
      end

      # TODO
      # def deserialize(fragment)
      #   CollectionDeserializer.new(self).deserialize(fragment)
      # end
    end

    class Mapping < ::Roaster::Decorator
      include Representable::JSON

      def to_hash(option)
        obj = {'id' => resource_id.to_s}.merge super(option)
        if option[:single_resource].nil?
          obj
        else
          { self.class.get_resource_name => obj }
        end
      end

    end
  end
end
