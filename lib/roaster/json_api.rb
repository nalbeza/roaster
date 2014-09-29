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

      #TODO: First stop when refactoring (links should be in definitions, not custom _has_one if possible)
      # Make roar's _links definition technique work in here
      def to_hash(option)
        roaster_type = option[:roaster]
        @adapter_class = option[:adapter_class]
        links = {}
        raw_links = {}

        representable_attrs[:_has_one].each do |link|
          representable_attrs[:definitions].delete(link[:name].to_s)
          mapping_class = Roaster::Factory.mapping_class_from_name((link[:mapping] || link[:name]).to_s.pluralize)
          links[link[:as].to_s] = {
            'id' => @adapter_class.one_linked_id(@represented, link[:name]),
            'type' => mapping_class.get_resource_name
          }
         raw_links[link[:as]] = {
            'type' => mapping_class.get_resource_name,
            'name' => link[:name],
            'mapping' => link[:mapping]
         }
        end unless representable_attrs[:_has_one].nil?


        representable_attrs[:_has_many].each do |link|
          representable_attrs[:definitions].delete(link[:name].to_s)
          mapping_class = Roaster::Factory.mapping_class_from_name((link[:mapping] || link[:name]).to_s.pluralize)
          links[link[:as].to_s] = {
            'ids' => @adapter_class.many_linked_ids(@represented, link[:name]),
            'type' => mapping_class.get_resource_name
          }
         raw_links[link[:as]] = {
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
              'linked' => {}
            })
            option[:query].includes.each do |inc|
              wrapper['linked'][inc.to_s] ||= Set.new
              raise "Athorizations error" if raw_links[inc].nil?
              link = raw_links[inc]
              mapping_class = Roaster::Factory.mapping_class_from_name((link[:mapping] || link[:name]).to_s.pluralize)
              wrapper['linked'][inc.to_s].merge mapping_class.for_collection.prepare(@adapter_class.linked(@represented, link[:name])).to_hash({roaster: :collection, adapter_class: @adapter_class, query: @query, resource_namespace: inc.to_s})
            end
          end
          case roaster_type
            when :resource
              wrapper['linked'].each do |k, v|
                wrapper['linked'][k] = v.to_a
              end if wrapper['linked']
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
