require 'representable/decorator'

require 'roaster/json_api'

module Roaster

  class Decorator < Representable::Decorator

    #include Representable::Hash
    #extend Roaster::JsonApi

    #representable_attrs[:_filterable_attributes] ||= []
    #representable_attrs[:_includeable_attributes] ||= []
    #representable_attrs[:_sortable_attributes] ||= []

    class << self
=begin
      def collection_representer_class
        @collection_representer_class
        Representable::Hash::Collection
      end
=end

      def can_filter_by(*attrs)
        representable_attrs[:_filterable_attributes] ||= []
        representable_attrs[:_filterable_attributes].push(*attrs.map(&:to_sym)).uniq!
      end

      def filterable_attributes
        representable_attrs[:_filterable_attributes] ||= []
        representable_attrs[:_filterable_attributes]
      end

      #TODO: Disallow sorting directly by relationship (need relationship field)
      def can_sort_by(*attrs)
        representable_attrs[:_sortable_attributes] ||= []
        sort_keys = attrs.map do |option|
          if option.class == Hash
            { option.first[0].to_sym => option.first[1].map(&:to_sym) }
          else
            option.to_sym
          end
        end
        representable_attrs[:_sortable_attributes].push(*sort_keys).uniq!
      end

      def sortable_attributes
        representable_attrs[:_sortable_attributes] ||= []
        representable_attrs[:_sortable_attributes]
      end

      def can_include(*attrs)
        representable_attrs[:_includeable_attributes] ||= []
        representable_attrs[:_includeable_attributes].push(*attrs.map(&:to_sym)).uniq!
      end

      def includeable_attributes
        representable_attrs[:_includeable_attributes] ||= []
        representable_attrs[:_includeable_attributes]
      end

    end

  end

end
