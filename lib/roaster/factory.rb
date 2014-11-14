module Roaster
  class Factory
    class << self
      def mapping_class_from_target(target)
        resource_mapping = mapping_class_from_name(target.resource_name)
        if target.relationship_name
          all_rels = resource_mapping.representable_attrs.values_at(:_has_many, :_has_one).flatten
          r = all_rels.find {|r| r[:as].to_sym == name.to_sym }
          rel_name = r && r[:mapping] ? r[:mapping] : target.relationship_name
          mapping_class_from_name(rel_name)
        else
          resource_mapping
        end
      end

      def mapping_class_from_name(name)
        "#{name.to_s.singularize}_mapping".classify.constantize
      end
    end
  end
end
