module Thoreau
  module V2
    module DSL
      class Cases

        attr_reader :context

        def initialize(context)
          @context = context
        end

        def logger *args
          @context.logger *args
        end

        include Thoreau::V2::DSL::TestCasesSupport

      end

    end
  end
end
