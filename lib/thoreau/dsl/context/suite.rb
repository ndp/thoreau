require 'active_support'
require 'active_support/core_ext/module/delegation'

module Thoreau
  module DSL
  module Context

    class Suite

      include Thoreau::Logging

      attr_reader :suite_data
      attr_reader :test_clan_model

      def initialize suite_data:, test_clan_model:
        raise "Suites must have (unique) names." if suite_data.name.blank?
        @suite_data = suite_data
        @test_clan_model  = test_clan_model
      end

      delegate :name, to: :suite_data

      def cases(name = nil, &block)
        name = self.suite_data.name if name.nil?
        logger.debug "   + adding cases named `#{name}`"
        @suite_data.test_cases_blocks << [name, block]
      end

      alias test_cases cases

      def appendix(&block)
        logger.debug "   adding appendix block"
        @suite_data.appendix_block = block
      end

    end

  end
end
end
