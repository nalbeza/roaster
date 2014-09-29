require 'active_record'

module Roaster
  module Adapters

    class ActiveRecord

      class << self
        def model_class_from_resource_name(resource_name)
          "#{resource_name.to_s.singularize}".classify.constantize
        end

        def many_linked_ids(resource, link_name)
          # byebug
          (resource.send(link_name.to_s.singularize + '_ids') || []).map(&:to_s)
        end

        def one_linked_id(resource, link_name)
          resource.send(link_name.to_s + '_id') ? resource.send(link_name.to_s. + '_id').to_s : nil
        end
      end

      #TODO: Query shouldn't be here
      def new(query, model_class: nil)
        model = model_for(model_class || query.target.resource_name)
        model.new
      end

      #TODO: HAX, rethink data path for POST/PUT requests from the start
      #TODO: #save! not good if we want to delay adapter request execution
      def save(model)
        model.save!
      end

      #TODO: Underscore does not mean private, only `private` does
      #TODO: Please refactor me, i'm ugly
      def _change_relationship(object, rel_name, rel_ids, replace: false)
        #TODO: Refactor model searching
        rel_model = rel_name.to_s.classify.constantize
        rel_meta = object.class.reflect_on_association(rel_name)
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

      def _change_relationships(object, rels, replace: false)
        rels.each do |name, v|
          _change_relationship(object, name, v, replace: replace)
        end
      end

      #TODO:
      # Document key isn't always rel_name, it's rel_name's resource type
      #   ( not accessible here right now :-( )
      def create_relationships(object, rels)
        _change_relationships(object, rels)
      end

      def update_relationships(object, rels)
        _change_relationships(object, rels, replace: true)
      end

      def find(res_name, res_ids, model_class: nil)
        model_class = model_for(model_class || res_name)
        raise 'No IDs given' if res_ids.empty?
        #TODO: Not sure if this is a good idea to handle this here
        model_class.find(res_ids.size == 1 ? res_ids.first : res_ids)
      end

      def read(query, model_class: nil)
        q = scope_for(query.target, model_class)
        query.includes.each do |i|
          q = q.include(i)
        end
        query.filters.each_pair do |k, v|
          q = q.where(k => v)
        end
        query.sorting.each do |resource_name, criteria|
          criteria.each do |field, direction|
            q = q.order(model_for(resource_name).arel_table[field].send(direction))
          end
        end
        q
      end

      def delete(query, model_class: nil)
        q = scope_for(query.target, model_class)
        q.destroy_all
      end

      private

      def resource_for(resource_name, id = nil)
      end

      def model_for(model_class_or_name)
        if model_class_or_name.kind_of?(Class) && model_class_or_name <= ::ActiveRecord::Base
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
