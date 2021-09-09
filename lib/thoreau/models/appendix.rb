module Thoreau
  module Models
    class Appendix

      attr_reader :setups

      def initialize setups: {}
        @setups = setups
      end

      def add_setup setup
        raise "Duplicate setup block #{setup.name}" unless setups[setup.name].nil?
        @setups[setup.name] = setup
      end
    end
  end
end
