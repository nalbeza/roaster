module Roaster

  class Resource

    def adapter
      @adapter
    end

    def initialize(adapter_class, opts = {})
      @adapter = adapter_class.new
      @model_class = opts[:model_class]
      @scope = opts[:scope]
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

    def query(query, api_key: nil)
      @adapter.read(query, model_class: @model_class, scope: @scope ? @scope.call(api_key)[:read] : nil)
    end

  end

end
