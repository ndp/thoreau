module Thoreau
  module DSL
    module Context
      class TestCases

        include Thoreau::Logging

        attr_reader :test_clan_model

        def initialize(clan_model, &context)
          @test_clan_model = clan_model

          self.instance_eval(&context)
        end

        include Thoreau::DSL::Context::Clan

      end
    end
  end
end
