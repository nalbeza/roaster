module Roaster
  class Request

    ALLOWED_OPERATIONS = [:create, :read, :update, :delete]

    def initialize(operation, resource, params, opts = {})
      # :create, :read, :update, :delete
      unless ALLOWED_OPERATIONS.include?(operation)
        raise "#{operation} is not a valid operation."
      end
      @operation = operation
      @resource = resource
      @mapping_class = opts[:mapping_class] || mapping_class_from_target(@resource.target)
      @query = Roaster::Query.new(@operation, @mapping_class, params)
      @input_resource = opts[:input_resource]
    end

    def execute
      res = @resource.send(@operation, @query)
      case @operation
      when :create
        obj = @resource.new_instance
        @mapping_class.represent(obj).from_hash(@input_resource)
        obj.save!
        obj
      when :read
        res = @resource.query(query)
        @mapping_class.represent(res).to_hash
      when :update
        obj = @resource.find_instance
        @mapping_class.represent(obj).from_hash(@input_resource)
        obj.save!
        obj
      when :delete
        @resource.delete_instance
      end
    end

    #TODO: Move this elsewhere (factory)
    def self.mapping_class_from_target(target)
      "#{target.resource_name.to_s.singularize}_mapping".classify.constantize
    end

  end
end
