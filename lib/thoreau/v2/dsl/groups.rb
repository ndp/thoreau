module Thoreau
  module V2
    module DSL
      class Groups

        attr_reader :context

        def initialize(context)
          @context = context
        end

        def logger *args
          @context.logger *args
        end

        include Thoreau::V2::DSL::GroupsSupport

      end

    end
  end
end
