module Roaster
  module Adapters

    class ActiveRecord

      def initialize(model_class)
        @model_class = model_class
      end

      def scope_for(target)
        scope = @model_class.all
        unless target.ids.empty?
          scope = scope.where(id: target.ids)
        end
        scope
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
        puts '===================== FINAL QUERY: ====================='
        puts q.to_sql
        puts '========================================================'
        q
      end

      def update(query)
        q = self.scope_for(query.target)
        query.filters.each_pair do |k, v|
          q = q.where(k => v)
        end
        puts '===================== FINAL QUERY: ====================='
        puts q.to_sql
        puts '========================================================'
        q
      end

      def delete(query)
        q = self.scope_for(query.target)
        query.filters.each_pair do |k, v|
          q = q.where(k => v)
        end
        puts '===================== FINAL QUERY: ====================='
        puts q.to_sql
        puts '========================================================'
        q
      end
    end

  end
end
