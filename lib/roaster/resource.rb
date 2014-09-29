module Roaster

  class Resource

    def initialize(adapter_class, opts = {})
      @adapter = adapter_class.new
      @model_class = opts[:model_class]
    end

    def new(query, model_class: @model_class)
      @adapter.new(query, model_class: model_class)
    end

    def save(model)
      @adapter.save(model)
      model
    end

    def delete(query)
      @adapter.delete(query, model_class: @model_class)
    end

    def change_relationships(object, rels, replace: false)
      @adapter.change_relationships(object, rels, replace: replace)
    end

    def find(res_name, res_ids)
      @adapter.find(res_name, res_ids, model_class: @model_class)
    end

    def query(query)
      @adapter.read(query, model_class: @model_class)
    end

  end

end
