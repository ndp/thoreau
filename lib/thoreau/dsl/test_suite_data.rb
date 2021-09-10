require_relative '../models/setup'

module Thoreau
  module DSL
    class TestSuiteData

      include Thoreau::Logging

      attr_accessor :appendix_block
      attr_reader :test_cases_blocks

      attr_reader :name
      attr_reader :test_clans

      def initialize name, appendix:, test_clan:
        @name              = name
        @appendix          = appendix
        @test_clans        = [test_clan]
        @test_cases_blocks = []
      end

      def add_setup(name, values, block)
        logger.debug "   Adding setup block #{name}"
        @appendix.add_setup Thoreau::Models::Setup.new(name, values, block)
      end

    end
  end
end
