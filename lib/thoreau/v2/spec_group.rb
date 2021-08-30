module Thoreau
  module V2

    class SpecGroup
      attr_reader :kind, :desc

      def initialize(kind:, desc:, spec:)
        @kind = kind
        @desc = desc
        @spec = spec
      end

      def inputs
        [@spec[:inputs] || @spec[:input] || {}].flatten
      end

      def expected_output
        @spec[:output] || @spec[:equals] || @spec[:equal]
      end

      def expected_exception
        @spec[:raises]
      end

      def setups
        [@spec[:setup], @spec[:setups]].flatten.compact
      end

      def failure_expected?
        @spec[:pending] || @spec[:fails]
      end
    end
  end
end

