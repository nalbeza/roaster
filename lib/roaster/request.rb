module Roaster
  class Request

    ALLOWED_OPERATIONS = [:create, :read, :update, :delete]

    #TODO: Move this elsewhere (factory)
    def self.mapping_class_from_target(target)
      if target.relationship_name
        mapping_class_from_name(target.relationship_name)
      else
        mapping_class_from_name(target.resource_name)
      end
    end

    def self.mapping_class_from_name(name)
      "#{name.to_s.singularize}_mapping".classify.constantize
    end

    def initialize(operation, target, resource, params, opts = {})
      # :create, :read, :update, :delete
      unless ALLOWED_OPERATIONS.include?(operation)
        raise "#{operation} is not a valid operation."
      end
      @operation = operation
      @resource = resource
      @mapping_class = opts[:mapping_class] || self.class.mapping_class_from_target(target)
      @query = Roaster::Query.new(@operation, target, @mapping_class, params)
      #TODO: Oh snap this is confusing
      @document = opts[:document]
    end

    def execute
      case @operation
      when :create
        #TODO: - IDEA - Maybe make `new` return a fake 'relationship' object so a relationship special case wouldn't be needed
        if @query.target.relationship_name.nil?
          obj = @resource.new(@query)
          parse(obj, @document)
          @resource.save(obj)
        else
          @resource.create_relationship(@query, @document)
        end
      when :read
        res = @resource.query(@query)
        represent(res).to_hash
      when :update
        obj = @resource.find(@query)
        parse(obj, @document)
        @resource.save(obj)
      when :delete
        @resource.delete(@query)
      end
    end

    private

    def parse(object, data)
      rp = @mapping_class.new(object)
      rp.from_hash(data)
    end

    def represent(data)
      if data.respond_to?(:each)
        @mapping_class.for_collection.prepare(data)
      else
        @mapping_class.prepare(data)
      end
    end

  end
end
