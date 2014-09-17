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

      #TODO: Please refactor me, i'm ugly
      def _change_relationship(query, rel_name, rel_ids, replace: false)
        model = model_for(query.target.resource_name)
        object = model.find(query.target.resource_ids.first)
        rel_model = rel_name.to_s.classify.constantize
        rel_meta = model.reflect_on_association(rel_name)
        rel_object = rel_model.find(rel_ids)
        case rel_meta.macro
        when :has_many
          object.send(rel_name).clear if replace === true
          object.send(rel_name).push(rel_object)
        when :belongs_to
          object.send("#{rel_name}=", rel_object)
        else
          raise "#{rel_meta.macro} relationship not implemented"
        end
        self.save(object)
      end

      #TODO:
      # Document key isn't always rel_name, it's rel_name's resource type
      #   ( not accessible here right now :-( )
      def create_relationship(query, document)
        rel_name = query.target.relationship_name
        rel_ids = document[rel_name.to_s.pluralize]
        _change_relationship(query, rel_name, rel_ids)
      end

      def update_relationship(query, document)
        document.each do |rel_name, rel_ids|
          _change_relationship(query, rel_name.to_sym, rel_ids, replace: true)
        end
      end

      def find(query, model_class: nil)
        raise 'No ID provided' if query.target.resource_ids.empty?
        scope_for(query.target, model_class).first
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

      def delete(query)
        q = scope_for(query.target)
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
        if target.relationship_name
          raise "Cannot apply relationship #{target.relationship_name} to nil object" if scope.count == 0
          raise "Cannot apply relationship #{target.relationship_name} to more than one object" if scope.count > 1
          scope = scope.first.send(target.relationship_name)
        end
        scope
      end

    end

  end
end
