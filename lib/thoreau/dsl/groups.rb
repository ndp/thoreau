module Thoreau
  module DSL
    class Groups

      attr_reader :context

      def initialize(context, &group_context)
        @context = context
        self.instance_eval(&group_context)
      end

      def logger *args
        @context.logger *args
      end

      include Thoreau::DSL::GroupsSupport

    end

  end
end
