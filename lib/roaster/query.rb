module Roaster

  # Query represents the operation performed on the target, and its parameters 
  class Query

    # Target represents the resource(s) scope on which is executed the query
    class Target

      attr_accessor :resource_name, :resource_ids, :relationship_name, :relationship_ids

      def initialize(resource_name,
                     resource_ids = [],
                     relationship_name = nil,
                     relationship_ids = [])
        @resource_name = resource_name
        @resource_ids = Array(resource_ids)
        @relationship_name = relationship_name
        @relationship_ids = Array(relationship_ids)
      end

    end

    #TODO: This is not validating includes it seems (HARD VALIDATE EVERYTHING, raise is your FRIEND)
    attr_accessor :page, :page_size, :includes, :fields, :filters,
                  :target,
                  :sorting,
                  :operation

    #TODO: Move in config class
    DEFAULT_PAGE_SIZE = 25
    DEFAULT_MAX_PAGE_SIZE = 100
    OPERATIONS = [:create, :read, :update, :delete]

    def initialize(operation, target, mapping, params = {})
      raise "Invalid operation: #{operation}" unless OPERATIONS.include?(operation)
      params.symbolize_keys! if params.respond_to?(:symbolize_keys!)

      @operation = operation
      @target = target
      max_page_size = mapping.representable_attrs[:_max_page_size] || DEFAULT_MAX_PAGE_SIZE
      # byebugz
      @page_size = (params[:page] && params[:page]['size'] ? params[:page]['size'].to_i : nil) || mapping.representable_attrs[:_page_size] || DEFAULT_PAGE_SIZE
      raise "Invalid page size" if @page_size > max_page_size
      @page = params[:page] && params[:page]['number'] ? params[:page]['number'].to_i : 0
      @includes = includes_from_params(params, mapping)
      @fields = fields_from_params(params, mapping)
      @filters = filters_from_params(params, mapping)
      @sorting = sorting_from_params(params, mapping)
      #VALIDATE THIS (TARGET) ! omgz =D
      @mapping = mapping
    end

    # TODO: REMOVE ?
    def default_page_size?
      @page_size == DEFAULT_PAGE_SIZE
    end

    def filters_as_url_params
      return nil if @filters.blank?
      @filters.sort.map { |k,v| map_filter_ids(k,v) }.join('&')
    end

    def sorting_as_url_params
      return nil if sorting.blank? || sorting[@target.resource_name].blank?
      sorting_values = sorting[@target.resource_name].map { |k, v| v == :asc ? k : "-#{k}" }.join(',')
      "sort=#{sorting_values}"
    end

    private

    def includes_from_params(params, mapping)
      return [] unless params[:include] && params[:include].respond_to?(:split)
      includes = params[:include].split(',').map(&:to_sym)
      includes.select do |i|
        mapping.includeable_attributes.include?(i)
      end
    end

    def parse_fieldset(fields)
      fields.to_s.split(',').collect do |field|
        field.downcase.to_sym
      end
    end

    def fields_from_params(params, mapping)
      return {} if params[:fields].blank?
      if params[:fields].class == Hash
        Hash[params[:fields].collect do |resource_name, fieldset|
            [resource_name.downcase.to_sym, parse_fieldset(fieldset)]
          end
        ]
      else
        {@target.resource_name => parse_fieldset(params[:fields])}
      end
    end

    def filters_from_params(params, mapping)
      filters = {}
      mapping.filterable_attributes.each do |filter|
        filters[filter] = params[filter] if params[filter]
      end
      filters
    end

    def parse_sort_criteria(criteria)
      sorting_parameters = {}
      criteria.to_s.split(',').each do |sort_value|
        sort_order = sort_value[0] == '-' ? :desc : :asc
        sort_value = sort_value.gsub(/\A\-/, '').downcase.to_sym
        sorting_parameters[sort_value] = sort_order
      end
      sorting_parameters
    end

    def validate_sorting_parameters(sort, mapping)
    end

    def sorting_from_params(params, mapping)
      return {} if params[:sort].blank? || mapping.sortable_attributes.blank?
      if params[:sort].class == Hash
        sorting_parameters = {}
        params[:sort].each do |sorting_resource|
          sorting_parameters[sorting_resource[0].to_sym] = parse_sort_criteria sorting_resource[1]
        end
        sorting_parameters
      else
        {@target.resource_name => parse_sort_criteria(params[:sort])}
      end
    end

    def map_filter_ids(key,value)
      case value
      when Hash
        value.map { |k,v| map_filter_ids(k,v) }
      else
         "#{key}=#{value.join(',')}"
      end
    end

    def query_to_array(value)
      case value
        when String
          value.split(',')
        when Hash
          value.each { |k, v| value[k] = query_to_array(v) }
        else
          value
      end
    end
  end
end
