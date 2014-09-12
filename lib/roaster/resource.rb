module Roaster

  class Resource
    
    attr_reader :target

    def initialize(target, opts = {})
      @target = target
    end

  end

end
