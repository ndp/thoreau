module Thoreau
  module DSL
    module Context
      class Appendix
        def initialize(appendix_model, &appendix_block)
          @model = appendix_model
          self.instance_eval(&appendix_block)
        end

        def setup name, values = {}, &block
          @model.add_setup(name, values, block)
        end

      end
    end
  end
end
