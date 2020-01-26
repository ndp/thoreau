require_relative('../thoreau')
require 'active_support/core_ext/hash'

module Thoreau
  module Minitest

    module DSL
      def thoreau(&block)
        dsl_context = Thoreau::DSLContext.new
        dsl_context.instance_eval(&block)
        dsl_context.verify_config!
        dsl_context.lock!

        dsl_context.each_equivalence_class do |ec|
          describe ec.setup_key do
            ec.each_test do |setup_block, action_block, assertion|
              temp_context = Object.new
              setup_value  = setup_block.call(temp_context)

              specify "#{ec.setup_key} #{assertion.desc} when  #{setup_value.to_s.truncate(30)}" do

                # Transfer any variables set in the `setup` into the
                # actual test context
                temp_context.instance_variables.each do |iv|
                  self.instance_variable_set(iv, temp_context.instance_variable_get(iv))
                end

                # Action
                result = self.instance_exec(setup_value, &action_block) if action_block

                # Assertion
                assertion.exec_in_context(self, result, setup_value)
              end
            end
          end
        end

      end
    end
  end
end
