module Roaster

  class ResourceNotFoundError < StandardError; end

  class Request

    ALLOWED_OPERATIONS = [:create, :read, :update, :delete]


    def initialize(operation, target, resource, params, opts = {})
      # :create, :read, :update, :delete
      unless ALLOWED_OPERATIONS.include?(operation)
        raise "#{operation} is not a valid operation."
      end
      @operation = operation
      @resource = resource
      @resource_mapping_class = Roaster::Factory.mapping_class_from_name(target.resource_name)
      @mapping_class = opts[:mapping_class] || Roaster::Factory.mapping_class_from_target(target)
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
          represent(res, singular: true)
        else
          obj = @resource.find(@query.target.resource_name, @query.target.resource_ids)
          @resource.create_relationships(obj, {@query.target.relationship_name => @document})
          nil
        end
        #TODO: Notify caller if the resource was created, or only links, useful for JSONAPI spec (HTTP 201 or 204)
      when :read
        res = @resource.query(@query)
        target = @query.target
        rel_name = target.relationship_name
        singular = target.resource_ids.size == 1 && rel_name.nil?
        if rel_name
          has_one_attrs = @resource_mapping_class.representable_attrs[:_has_one]
          singular = has_one_attrs && has_one_attrs.one? {|h| h[:name] == rel_name }
        end
        raise ResourceNotFoundError if res.blank? && singular
        represent(res, singular: singular)
      when :update
        obj = @resource.find(@query.target.resource_name, @query.target.resource_ids)
        links = @document.delete('links')
        @resource.update_relationships(obj, links) if links
        parse(obj, @document) unless @document.empty?
        @resource.save(obj)
        @document.empty? ? nil : represent(obj, singular: true)
        #TODO: Notify caller if the resource itself was updated, or only links, useful for JSONAPI spec (HTTP 200 or 204)
      when :delete
        @resource.delete(@query)
        nil
      end
    end

    private

    def parse(object, data)
      rp = @mapping_class.new(object)
      rp.from_hash(data)
    end

    def represent(data, singular: false)
      if singular && data.respond_to?(:first)
        @mapping_class.prepare(data.first).to_hash({roaster: :resource, resource: @resource})
      elsif data.respond_to?(:each)
        @mapping_class.for_collection.prepare(data).to_hash({roaster: :collection, resource: @resource},
          Roaster::JsonApi::CollectionBinding)
      else
        @mapping_class.prepare(data).to_hash({roaster: :resource, resource: @resource})
      end
    end

  end
end
