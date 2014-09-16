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
    attr_accessor :page, :page_size, :includes, :filters,
                  :target,
                  :sorting,
                  :operation

    #TODO: Move in config class
    DEFAULT_PAGE_SIZE = 10
    OPERATIONS = [:create, :read, :update, :delete]

    def initialize(operation, target, mapping, params = {})
      raise "Invalid operation: #{operation}" unless OPERATIONS.include?(operation)
      params.symbolize_keys! if params.respond_to?(:symbolize_keys!)

      @operation = operation
      @target = target
      @page = params[:page] ? params[:page].to_i : 1
      @page_size = params[:page_size] ? params[:page_size].to_i : DEFAULT_PAGE_SIZE
      @includes = includes_from_params(params, mapping)
      @filters = filters_from_params(params, mapping)
      @sorting = sorting_from_params(params, mapping)
      #VALIDATE THIS (TARGET) ! omgz =D
      @mapping = mapping
    end

    def default_page_size?
      @page_size == DEFAULT_PAGE_SIZE
    end

    def filters_as_url_params
      @filters.sort.map { |k,v| map_filter_ids(k,v) }.join('&')
    end

    def sorting_as_url_params
      sorting_values = sorting.map { |k, v| v == :asc ? k : "-#{k}" }.join(',')
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

    def sorting_from_params(params, mapping)
      return {} if params[:sort].blank? || mapping.sortable_attributes.blank?
      if params[:sort].class == Hash
        sorting_parameters = {}
        params[:sort].each do |sorting_resource|
          sorting_parameters[sorting_resource[0].to_sym] = parse_sort_criteria sorting_resource[1]
        end
        sorting_parameters
      else
        parse_sort_criteria(params[:sort])
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
