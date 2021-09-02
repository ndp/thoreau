require_relative '../setup'

module Thoreau
  module DSL
    class Appendix
      def initialize(context, &appendix_block)
        @context = context
        self.instance_eval(&appendix_block)
      end

      def setup name, values = {}, &block
        raise "duplicate setup block #{name}" unless @context.setups[name].nil?
        @context.setups[name.to_s] = Thoreau::Setup.new(name, values, block)
      end

    end

  end
end
