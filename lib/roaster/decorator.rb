require 'representable/decorator'

require 'roaster/json_api'

module Roaster

  class Decorator < Representable::Decorator

    include Representable::JSON
    #extend Roaster::JsonApi

    representable_attrs[:_filterable_attributes] ||= []
    representable_attrs[:_includeable_attributes] ||= []
    representable_attrs[:_sortable_attributes] ||= []

    class << self

      def collection_representer_class
        Representable::Hash::Collection
      end

      def can_filter_by(*attrs)
        representable_attrs[:_filterable_attributes].push(*attrs.map(&:to_sym)).uniq!
      end

      def filterable_attributes
        representable_attrs[:_filterable_attributes]
      end

      def can_sort_by(*attrs)
        representable_attrs[:_sortable_attributes].push(*attrs.map(&:to_sym)).uniq!
      end

      def sortable_attributes
        representable_attrs[:_sortable_attributes]
      end

      def can_include(*attrs)
        representable_attrs[:_includeable_attributes].push(*attrs.map(&:to_sym)).uniq!
      end

      def includeable_attributes
        representable_attrs[:_includeable_attributes]
      end

    end

  end

end
