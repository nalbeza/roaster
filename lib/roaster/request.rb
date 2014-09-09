module Roaster
  class Request

    ALLOWED_OPERATIONS = [:create, :read, :update, :delete]

    def initialize(operation, mapping_class, db_adapter, query)
      # :create, :read, :update, :delete
      unless ALLOWED_OPERATIONS.include?(operation)
        raise "#{operation} is not a valid operation."
      end
      @operation = operation
      @mapping_class = mapping_class
      @db_adapter = db_adapter
      @query = query
    end

    def execute
      res = @db_adapter.send(@operation, @query)
      BlogPostCategoryMeal.for_collection.prepare(res)
    end

  end
end
