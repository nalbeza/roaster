module Roaster
  class Factory
    class << self
      def mapping_class_from_target(target)
        if target.relationship_name
          mapping_class_from_name(target.relationship_name)
        else
          mapping_class_from_name(target.resource_name)
        end
      end

      def mapping_class_from_name(name)
        "#{name.to_s.singularize}_mapping".classify.constantize
      end
    end
  end
end