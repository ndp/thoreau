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
          ec.each_test do |setup_block, action_block, assertion|
            temp_context = Object.new
            setup_value  = setup_block.call(temp_context)
            description  = (setup_block.respond_to?(:description) ? setup_block.description : ec.setup_key.to_s)
            description  += ' ' + assertion.description

            specify description do

              ## Transfer any variables set in the `setup` into the
              ## actual test context
              temp_context.instance_variable_set(:@_outer_self, self)
              def temp_context.method_missing(m, *args, &block)
                @_outer_self.send(m, *args, &block)
              end

              result = action_block ? temp_context.instance_exec(ExampleGroupHelpers.implicit_param(setup_value), &action_block) : setup_value

              assertion.exec_in_context(temp_context, ExampleGroupHelpers.implicit_param(result), setup_value)
            end
          end
        end
      end

      def self.implicit_param(params)
        params.is_a?(Hash) &&
          params.keys == [SetupAssembler::IMPLICIT_VAR_NAME] ?
          params[SetupAssembler::IMPLICIT_VAR_NAME] : params
      end
    end
  end
end
