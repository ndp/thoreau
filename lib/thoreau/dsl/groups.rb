module Thoreau
  module DSL
    class Groups

      attr_reader :suite_data
      attr_reader :logger

      def initialize(context, &group_context)
        @logger = context.logger
        @suite_data = context.suite_data

        self.instance_eval(&group_context)
      end

      include Thoreau::DSL::GroupsSupport

    end

  end
end
