require 'forwardable'
require 'active_support'
require 'active_support/core_ext/hash'

module Thoreau
  module Rspec
    module ExampleGroupHelpers

      extend Forwardable

      def_delegator :thoreau_context, :cases, :cases
      def_delegator :thoreau_context, :setup, :setup
      def_delegator :thoreau_context, :action, :action
      def_delegator :thoreau_context, :asserts, :asserts

      def thoreau_context
        metadata[:thoreau_context] ||= Thoreau::DSLContext.new
      end

      def generate!
        thoreau_context.verify_config!

        thoreau_context.each_equivalence_class do |ec|
          describe ec.setup_key do
            ec.each_test do |setup_block, action_block, assertion|
              temp_context = Object.new
              setup_value  = setup_block.call(temp_context)
              setup_value_str = (setup_value || 'nil').to_s.truncate(30)
              description     = "" + assertion.description
              description += " when given #{setup_value_str}" unless setup_value_str.match?(/^\[?#</) || description.include?(setup_value_str)

              it description do

                # Transfer any variables set in the `setup` into the
                # actual test context
                temp_context.instance_variables.each do |iv|
                  self.instance_variable_set(iv, temp_context.instance_variable_get(iv))
                end

                # Action
                result = action_block ? self.instance_exec(setup_value, &action_block) : setup_value

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
