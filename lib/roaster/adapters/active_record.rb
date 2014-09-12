require 'active_record'

module Roaster
  module Adapters

    class ActiveRecord

      def initialize(model_class)
        if model_class.kind_of?(::ActiveRecord::Base)
          @model_class = model_class
        else
          @model_class = self.class.model_class_from_resource_name(model_class)
        end
      end

      def self.model_class_from_resource_name(resource_name)
        "#{resource_name.to_s.singularize}".classify.constantize
      end

      def create(query)
      end

      def read(query)
        q = self.scope_for(query.target)
        query.include.each do |i|
          q = q.include(i)
        end
        query.filters.each_pair do |k, v|
          q = q.where(k => v)
        end
        sort_q = query.sorting.map do |key, order|
          q = q.order(key => order)
        end
        q
      end

      def update(query)
        q = self.scope_for(query.target)
        query.filters.each_pair do |k, v|
          q = q.where(k => v)
        end
        q
      end

      def delete(query)
        q = self.scope_for(query.target)
        q.destroy_all
        q
      end

      private

      def resource_for(resource_name, id = nil)
      end

      #TODO: Handle ALL, none should be the default
      def scope_for(target)
        scope = @model_class.all
        unless target.ids.empty?
          scope = scope.where(id: target.ids)
        end
        scope
      end

    end

  end
end
