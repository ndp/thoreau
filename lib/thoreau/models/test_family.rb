module Thoreau
  module Models

    class TestFamily
      attr_reader :asserts,
                  :expected_exception,
                  :expected_output,
                  :kind,
                  :setups
      attr_writer :focus
      attr_accessor :use_legacy_snapshot
      attr_accessor :desc

      def initialize(asserts:,
                     desc:,
                     expected_exception:,
                     expected_output:,
                     failure_expected:,
                     input_specs:,
                     kind:,
                     setups:
      )
        @asserts            = asserts
        @desc               = desc
        @expected_exception = expected_exception
        @expected_output    = expected_output
        @failure_expected   = failure_expected
        @input_specs        = input_specs
        @kind               = kind
        @setups             = setups
      end

      def input_specs
        @input_specs.size == 0 ?
          [{}] : @input_specs
      end

      def failure_expected?
        @failure_expected
      end

      def focused?
        @focus
      end

      def to_s
        "#{@desc || "#{@kind} #{(@input_specs.map &:to_s).to_sentence } expect #{expected_output}"}"
      end

    end
  end
end

