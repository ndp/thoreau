module Thoreau
  module DSL
    class Groups

      include Thoreau::Logging

      attr_reader :suite_data

      def initialize(context, &group_context)
        @suite_data = context.suite_data

        self.instance_eval(&group_context)
      end

      include Thoreau::DSL::GroupsSupport

    end

  end
end
