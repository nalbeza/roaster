module Roaster

  class ResourceNotFoundError < StandardError; end

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
      unless ALLOWED_OPERATIONS.include?(operation)
        raise "#{operation} is not a valid operation."
      end
      @operation = operation
      @resource = resource
      #TODO: This shouldnt be here, mapping_class option does not work when getting relationship (returns relationship type, not resource type)
      @resource_mapping_class = opts[:mapping_class] || self.class.mapping_class_from_name(target.resource_name)
      @mapping_class = opts[:mapping_class] || self.class.mapping_class_from_target(target)
      @query = Roaster::Query.new(@operation, target, @mapping_class, params)
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
          change_relationships(obj, links) if links
          represent(res, singular: true)
        else
          obj = @resource.find(@query.target.resource_name, @query.target.resource_ids)
          change_relationships(obj, {@query.target.relationship_name => @document})
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
        change_relationships(obj, links, replace: true) if links
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

    def change_relationships(obj, rels, replace: false)
      rels = resolve_relationships(rels)
      @resource.change_relationships(obj, rels, replace: replace)
    end

    #TODO: Move/fix this (mapping should expose some clean way to inspect relationships) !
    def resolve_relationships(rels)
      Hash[rels.map do |name, v|
        rname = [:_has_one, :_has_many].map do |k|
          ra = @resource_mapping_class.representable_attrs[k]
          next nil unless ra
          r = ra.find {|r| r[:as].to_sym == name.to_sym }
          r ? r[:name] : nil
        end.compact.first
        raise "Unknown rel: #{name}" unless rname
        [rname, v]
      end]
    end

    def parse(object, data)
      rp = @mapping_class.new(object)
      rp.from_hash(data)
    end

    def represent(data, singular: false)
      if singular && data.respond_to?(:first)
        @mapping_class.prepare(data.first).to_hash({roaster: :resource})
      elsif data.respond_to?(:each)
        @mapping_class.for_collection.prepare(data).to_hash({roaster: :collection}, Roaster::JsonApi::CollectionBinding)
      else
        @mapping_class.prepare(data).to_hash({roaster: :resource})
      end
    end

  end
end
