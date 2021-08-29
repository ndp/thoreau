module Thoreau
  module V2

    class SpecGroup
      attr_reader :kind, :desc, :args

      def initialize(kind:, desc:, spec:)
        @kind = kind
        @desc = desc
        @spec = spec
      end

      def inputs
        [@spec[:inputs] || @spec[:input] || {}].flatten
      end

      def expected_output
        @spec[:output]
      end

      def expected_exception
        @spec[:raises]
      end
    end
  end
end

