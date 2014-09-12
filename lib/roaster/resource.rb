module Roaster

  class Resource
    
    attr_reader :target

    def initialize(target, adapter_class, opts = {})
      @target = target
      model_class = opts[:model_class] || self.class.model_class_from_target(target)
      @adapter = adapter_class.new(model_class)
    end

    def query(query)
      @adapter.read(query)
    end

    #TODO: Move this elsewhere (factory)
    def self.model_class_from_target(target)
      "#{target.resource_name.to_s.singularize}".classify.constantize
    end

  end

end
