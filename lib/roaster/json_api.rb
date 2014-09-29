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
      end

      def linked(option, has_one, has_many)
        linked = {}
        option[:query].includes.each do |inc|
          link = has_one[inc] if has_one[inc]
          link = has_many[inc] if has_many[inc]
          # TODO: Handle duplication of keys between has one and has_many ?
          raise "{Error: #{inc.to_s} is includeable but cannot be found in your has_many or has_one relationships.}" if link.nil?
          mapping_class = Roaster::Factory.mapping_class_from_name((link[:mapping] || link[:name]).to_s.pluralize)
          if has_one[inc]
            linked[has_one[inc][:type]] ||= Set.new
            linked[has_one[inc][:type]].merge [mapping_class.prepare(@adapter_class.linked(@represented, link[:name])).to_hash({roaster: :resource, adapter_class: @adapter_class, query: nil, resource_namespace: inc.to_s})[has_one[inc][:type]]]
          elsif has_many[inc]
            linked[has_many[inc][:type]] ||= Set.new
            linked[has_many[inc][:type]].merge mapping_class.for_collection.prepare(@adapter_class.linked(@represented, link[:name])).to_hash({roaster: :collection, adapter_class: @adapter_class, query: nil, resource_namespace: inc.to_s})
          end
        end
        linked.each do |k, v|
          linked[k] = v.to_a
        end
      end

      #TODO: First stop when refactoring (links should be in definitions, not custom _has_one if possible)
      # Make roar's _links definition technique work in here
      def to_hash(option)
        roaster_type = option[:roaster]
        @adapter_class = option[:adapter_class]
        links = {}
        has_one = {}
        has_many = {}

        representable_attrs[:_has_one].each do |link|
          representable_attrs[:definitions].delete(link[:name].to_s)
          mapping_class = Roaster::Factory.mapping_class_from_name((link[:mapping] || link[:name]).to_s.pluralize)
          links[link[:as].to_s] = {
            'id' => @adapter_class.one_linked_id(@represented, link[:name]),
            'type' => mapping_class.get_resource_name
          }
          has_one[link[:as]] = {
            :type => mapping_class.get_resource_name,
            :name => link[:name],
            :mapping => link[:mapping]
         }
        end unless representable_attrs[:_has_one].nil?


        representable_attrs[:_has_many].each do |link|
          representable_attrs[:definitions].delete(link[:name].to_s)
          mapping_class = Roaster::Factory.mapping_class_from_name((link[:mapping] || link[:name]).to_s.pluralize)
          links[link[:as].to_s] = {
            'ids' => @adapter_class.many_linked_ids(@represented, link[:name]),
            'type' => mapping_class.get_resource_name
          }
          has_many[link[:as]] = {
            :type => mapping_class.get_resource_name,
            :name => link[:name],
            :mapping => link[:mapping]
         }
        end unless representable_attrs[:_has_many].nil?

        if roaster_type.nil?
          resource_id.to_s
        else
          sup = {'id' => resource_id.to_s }
          sup.merge!({'links' => links }) unless links.empty?
          wrapper = {}
          if option[:query] && option[:query].includes && option[:query].includes.size > 0
            wrapper.merge!({
              'linked' => linked(option, has_one, has_many) #TODO HERE
            })
          end
          case roaster_type
            when :resource
              {
                self.class.get_resource_name => sup.merge(super(option))
              }.merge! wrapper
            when :collection
              sup.merge(super(option))
          end
        end
      end

    end
  end
end
