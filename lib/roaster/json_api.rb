require 'roaster/decorator'
require 'representable/json'

require 'representable/bindings/hash_bindings'

module Roaster
  module JsonApi

    class CollectionBinding < Representable::Hash::PropertyBinding
      def self.build_for(definition, *args)
        self.new(definition, *args)
      end

      def serialize(value)
        @mapping_class = @definition[:extend].instance_variable_get('@value')
        collection = value.collect { |item|
          super(item)
        }
        { @mapping_class.get_resource_name => collection }
      end

      # TODO
      # def deserialize(fragment)
      #   CollectionDeserializer.new(self).deserialize(fragment)
      # end
    end

    class Mapping < ::Roaster::Decorator
      include Representable::JSON

      def from_hash(hash, options = {})
        return super
        super(hash[self.class.get_resource_name], options)
      end

      #TODO: First stop when refactoring (links should be in definitions, not custom _has_one if possible)
      # Make roar's _links definition technique work in here
      def to_hash(option)

        roaster_type = option[:roaster]
        links = {}

        representable_attrs[:_has_one].each do |link|
          representable_attrs[:definitions].delete(link[:name].to_s)
          links[link[:as]] = @represented[link[:key]].nil? ? nil : @represented[link[:key]].to_s
        end unless representable_attrs[:_has_one].nil?


        representable_attrs[:_has_many].each do |link|
          representable_attrs[:definitions].delete(link[:name].to_s)
          links[link[:as]] = @represented.send(link[:key]).map(&:to_s) || []
        end unless representable_attrs[:_has_many].nil?

        if roaster_type.nil?
          resource_id.to_s
        else
          sup = {'id' => resource_id.to_s }
          sup.merge!({'links' => links }) unless links.empty?
          case roaster_type
            when :resource
              {
                self.class.get_resource_name => sup.merge(super(option))
              }
            when :collection
              sup.merge(super(option))
          end
        end
      end

    end
  end
end
