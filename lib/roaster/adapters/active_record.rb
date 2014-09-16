require 'active_record'

module Roaster
  module Adapters

    class ActiveRecord

      def self.model_class_from_resource_name(resource_name)
        "#{resource_name.to_s.singularize}".classify.constantize
      end

      def new(query, model_class: nil)
        model = model_for(model_class || query.target.resource_name)
        model.new
      end

      #TODO: HAX, rethink data path for POST/PUT requests from the start
      #TODO: #save! not good if we want to delay adapter request execution
      def save(model)
        model.save!
      end

      def find(query, model_class: nil)
        scope_for(query.target, model_class).first
      end

      def create(query, model_class: nil)
      end

      def read(query, model_class: nil)
        q = scope_for(query.target, model_class)
        query.includes.each do |i|
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

      def model_for(model_class_or_name)
        if model_class_or_name.kind_of?(::ActiveRecord::Base)
          model_class_or_name
        else
          self.class.model_class_from_resource_name(model_class_or_name)
        end
      end

      #TODO: Handle ALL, none should be the default: maybe not ?
      # Move resource stuff into resource_for
      def scope_for(target, model_class_or_name = nil)
        model_class = model_for(model_class_or_name || target.resource_name)
        scope = model_class.all
        unless target.resource_ids.empty?
          scope = scope.where(id: target.resource_ids)
        end
        scope
      end

    end

  end
end
