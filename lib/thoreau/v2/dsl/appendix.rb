module Thoreau
  module V2
    module DSL
      class Appendix
        def initialize(context)
          @context = context
        end

        def inputs
        end

        def setups

        end

        def setup name, values = {}, &block
          raise "duplicate setup block #{name}" unless @context.setups[name].nil?
          @context.setups[name.to_s] = [values, block]
        end

        def outputs

        end

        def expectations

        end

      end

    end
  end
end
