module Roaster
  class Request

    ALLOWED_OPERATIONS = [:create, :read, :update, :delete]

    def initialize(mapping_class, db_adapter, query)
      # :create, :read, :update, :delete
      unless ALLOWED_OPERATIONS.include?(operation)
        raise "#{operation} is not a valid operation."
      end
      @mapping_class = mapping_class
      @db_adapter = db_adapter
      @query = query
    end

    def execute
      res = @db_adapter.send(@operation, @query)
      #@mapping_class.for_collection.prepare(res)
      @mapping_class.represent(res)
    end

  end
end
