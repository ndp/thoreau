module Thoreau
  module DSL
    class Groups

      attr_reader :context

      def initialize(context)
        @context = context
      end

      def logger *args
        @context.logger *args
      end

      include Thoreau::DSL::GroupsSupport

    end

  end
end
