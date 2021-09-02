require_relative '../setup'

module Thoreau
  module DSL
    class Appendix
      def initialize(data, &appendix_block)
        @data = data
        self.instance_eval(&appendix_block)
      end

      def setup name, values = {}, &block
        @data.add_setup(name, values, block)
      end

    end

  end
end
