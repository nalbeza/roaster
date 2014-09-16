module Roaster

  class Resource
    
    attr_reader :target

    def initialize(adapter_class, opts = {})
      @adapter = adapter_class.new
      @model_class = opts[:model_class]
    end

    def new(query)
      @adapter.new(query)
    end

    def save(model)
      @adapter.save(model)
      model
    end

    def find(query)
      @adapter.find(query, model_class: @model_class)
    end

    def query(query)
      @adapter.read(query, model_class: @model_class)
    end

    def model_class
    end

    #TODO: Move this elsewhere (factory)

  end

end
