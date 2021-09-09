require 'active_support/core_ext/module/delegation'

module Thoreau

  class OverriddenActionError < RuntimeError
    def initialize(msg = nil)
      super "Extra action/subject provided for tests. Actions/subjects must be specified EITHER in the `suite` or within `test_cases` (not both)."
    end
  end

  module Models
    class TestClan # set of TestFamilies

      include Thoreau::Logging

      attr_accessor :test_families, :appendix
      attr_reader :name, :action_block

      delegate :empty?, to: :test_families

      def initialize(name, appendix:, action_block: nil)
        @name          = name
        @test_families = []
        @appendix      = appendix
        @action_block  = action_block
      end

      def action_block= block
        raise OverriddenActionError unless @action_block.nil?
        @action_block = block
      end

      def add_test_family fam
        logger.debug "   + Adding test family #{fam}"
        fam.desc = self.name if fam.desc.blank?
        @test_families.push fam
        fam
      end

    end
  end
end
