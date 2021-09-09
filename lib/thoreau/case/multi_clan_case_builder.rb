module Thoreau
  module Case
    class MultiClanCaseBuilder

      include Logging

      def initialize(test_clans:)
        @case_builders = test_clans.map do |test_clan|
          CaseBuilder.new test_clan: test_clan
        end
      end

      def any_focused?
        @case_builders.any? &:any_focused?
      end

      def skipped_count
        return 0 unless any_focused?
        @case_builders.map(&:skipped_count).reduce(&:+)
      end

      def build_test_cases!
        @case_builders.flat_map(&:build_test_cases!)
      end
    end
  end
end
