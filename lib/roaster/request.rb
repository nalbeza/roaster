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
      @document = opts[:document] ? @mapping_class.strip(opts[:document]) : {}
    end

    def execute
      case @operation
      when :create
        if @query.target.relationship_name.nil?
          obj = @resource.new(@query)
          links = @document.delete('links')
          parse(obj, @document)
          #TODO: Allow rel creation before saving (has_one requires a single update query)
          res = @resource.save(obj)
          @resource.create_relationships(obj, links) if links
          represent(res)
        else
          obj = @resource.find(@query.target.resource_name, @query.target.resource_ids)
          @resource.create_relationships(obj, {@query.target.relationship_name => @document})
        end
      when :read
        res = @resource.query(@query)
        represent(res)
      when :update
        obj = @resource.find(@query.target.resource_name, @query.target.resource_ids)
        links = @document.delete('links')
        @resource.update_relationships(obj, links) if links
        parse(obj, @document) unless @document.empty?
        @resource.save(obj)
        #TODO: Notify caller if the resource itself was updated (not links), useful for JSONAPI spec (HTTP 200 or 204)
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
      if @query.target.resource_ids.size == 1
        @mapping_class.prepare(data.first).to_hash({roaster: :resource})
      elsif data.respond_to?(:each)
        @mapping_class.for_collection.prepare(data).to_hash({roaster: :collection}, Roaster::JsonApi::CollectionBinding)
      else
        @mapping_class.prepare(data).to_hash({roaster: :resource})
        # TODO: HANDLE ERROR ?
      end
    end

  end
end
