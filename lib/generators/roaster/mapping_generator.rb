require 'rails/generators/active_record'

module Roaster
  class MappingGenerator < ActiveRecord::Generators::Base
    desc 'Generates Roaster mappings from ActiveRecord models'

    argument :name, type: :string
    argument :output_path, type: :string, optional: true

    def self.source_root
      @source_root ||= File.join(File.dirname(__FILE__), 'templates')
    end

    def create_mapping
      model = name.camelize.constantize
      @properties = model.column_names
      @properties.delete('id')
      rel_lut = {has_many: :has_many, has_one: :has_one, belongs_to: :has_one}
      relationships = model.reflect_on_all_associations
      @relationships = relationships.select {|a| rel_lut.has_key?(a.macro) }.group_by {|a| rel_lut[a.macro] }
      path = File.join(output_path, "#{name}.rb")
      template('mapping.erb', "app/api/vidzit/mappings/#{name}.rb")
    end

  end
end
