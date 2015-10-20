require 'roaster/decorator'
require 'representable/json'

require 'representable/bindings/hash_bindings'

module Roaster
  module JsonApi

    class CollectionBinding < Representable::Hash::PropertyBinding
      def self.build_for(definition, *args)
        self.new(definition, *args)
      end

      def serialize_page_links(page)
        if page
          params = '?'
          if @filters
            params += @filters
          end
          if @sorting
            params += '&' if params.size != 1
            params += @sorting
          end
          params += '&' if params.size != 1
          params += 'page[number]=' + page.to_s + '&page[size]=' + @page_size.to_s
          @resources_url + params
        end
      end

      def serialize(value)
        @mapping_class  = @definition[:extend].instance_variable_get('@value')
        @resources_url  = @mapping_class.resources_url @user_options[:root_url]
        @page_size      = @user_options[:query].page_size
        @filters        = @user_options[:query].filters_as_url_params
        @sorting        = @user_options[:query].sorting_as_url_params
        page            = @user_options[:query].page
        collection_size = @user_options[:adapter_class].collection_size value
        pages_count     = (collection_size / @page_size.to_f).ceil
        collection      = @user_options[:adapter_class].paginate_collection(value, page, @page_size).collect { |item|
          super(item)
        }
        self_page = page
        first_page = 0
        last_page = pages_count - 1
        prev_page = page > 0 ? page - 1 : nil
        next_page = page < (pages_count - 1) ? page + 1 : nil
        {
          'data' => collection,
          'links' => {
            'self' => serialize_page_links(self_page),
            'first' => serialize_page_links(first_page),
            'last' => serialize_page_links(last_page),
            'prev' => serialize_page_links(prev_page),
            'next' => serialize_page_links(next_page)
          }
        }
      end

      # TODO
      # def deserialize(fragment)
      #   CollectionDeserializer.new(self).deserialize(fragment)
      # end
    end

    class Mapping < ::Roaster::Decorator
      include Representable::JSON

      class << self
        def resources_url(root_url)
          root_url + '/' + self.get_resource_name
        end
      end

      def from_hash(hash, options = {})
        return super
      end

      def linked(option, has_one, has_many)
        linked = []
        option[:query].includes.each do |inc|
          link = has_one[inc] if has_one[inc]
          link = has_many[inc] if has_many[inc]
          # TODO: Handle duplication of keys between has one and has_many ?
          raise "{Error: #{inc.to_s} is includeable but cannot be found in your has_many or has_one relationships.}" if link.nil?
          mapping_class = Roaster::Factory.mapping_class_from_name((link[:mapping] || link[:name]).to_s.pluralize)
          if has_one[inc]
            linked << mapping_class.prepare(@adapter_class.linked(@represented, link[:name])).to_hash({roaster: :resource, adapter_class: @adapter_class, query: nil, resource_namespace: inc.to_s, root_url: @root_url})[:data]
          elsif has_many[inc]
            linked.concat mapping_class.for_collection.prepare(@adapter_class.linked(@represented, link[:name])).to_hash({roaster: :collection, adapter_class: @adapter_class, query: nil, resource_namespace: inc.to_s, root_url: @root_url})
          end
        end
        linked
      end

      #TODO: First stop when refactoring (links should be in definitions, not custom _has_one if possible)
      # Make roar's _links definition technique work in here
      def to_hash(option)
        roaster_type = option[:roaster]
        @adapter_class = option[:adapter_class]
        @root_url = option[:root_url]
        links = {}
        has_one = {}
        has_many = {}

        representable_attrs[:_has_one].each do |link|
          representable_attrs[:definitions].delete(link[:name].to_s)
          mapping_class = Roaster::Factory.mapping_class_from_name((link[:mapping] || link[:name]).to_s.pluralize)
          links[link[:as].to_s] = {
            'data' => {
              'type' => mapping_class.get_resource_name,
              'id' => @adapter_class.one_linked_id(@represented, link[:name])
            }
          }
          has_one[link[:as]] = {
            :type => mapping_class.get_resource_name,
            :name => link[:name],
            :mapping => link[:mapping]
         }
        end unless representable_attrs[:_has_one].nil?


        representable_attrs[:_has_many].each do |link|
          representable_attrs[:definitions].delete(link[:name].to_s)
          mapping_class = Roaster::Factory.mapping_class_from_name((link[:mapping] || link[:name]).to_s.pluralize)
          links[link[:as].to_s] = {
            'data' => @adapter_class.many_linked_ids(@represented, link[:name]).map { |id|
              {
                'type' => mapping_class.get_resource_name,
                'id' => id
              }
            }
         }
          has_many[link[:as]] = {
            :type => mapping_class.get_resource_name,
            :name => link[:name],
            :mapping => link[:mapping]
         }
        end unless representable_attrs[:_has_many].nil?

        if roaster_type.nil?
          resource_id.to_s
        else
          sup = {'type' => self.class.get_resource_name}
          sup.merge!({'id' => resource_id.to_s })
          attributes = super(option)
          sup.merge!({'attributes' => attributes}) unless attributes.empty?
          sup.merge!({'relationships' => links }) unless links.empty?
          if @root_url
            sup['links'] ||= {}
            sup['links'].merge!({'self' => self.class.resources_url(@root_url) + '/' + resource_id.to_s })
          end
          wrapper = {}
          if option[:query] && option[:query].includes && option[:query].includes.size > 0
            wrapper.merge!({
              'included' => linked(option, has_one, has_many) #TODO HERE
            })
          end
          case roaster_type
            when :resource
              {
                data: sup
              }.merge! wrapper
            when :collection
              sup
          end
        end
      end

    end
  end
end
