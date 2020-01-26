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
        thoreau_context.lock!

        thoreau_context.each_equivalence_class do |ec|
          describe ec.setup_key do
            ec.each_test do |setup_block, action_block, assertion|
              temp_context = Object.new
              setup_value  = setup_block.call(temp_context)

              it "#{assertion.desc} when given #{(setup_value || 'nil').to_s.truncate(30)}" do

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


      #def path(template, metadata={}, &block)
      #  metadata[:path_item] = { template: template }
      #  describe(template, metadata, &block)
      #end
      #
      #[ :get, :post, :patch, :put, :delete, :head, :options, :trace ].each do |verb|
      #  define_method(verb) do |summary, &block|
      #    api_metadata = { operation: { verb: verb, summary: summary } }
      #    describe(verb, api_metadata, &block)
      #  end
      #end
      #
      #[ :operationId, :deprecated, :security ].each do |attr_name|
      #  define_method(attr_name) do |value|
      #    metadata[:operation][attr_name] = value
      #  end
      #end
      #
      ## NOTE: 'description' requires special treatment because ExampleGroup already
      ## defines a method with that name. Provide an override that supports the existing
      ## functionality while also setting the appropriate metadata if applicable
      #def description(value=nil)
      #  return super() if value.nil?
      #  metadata[:operation][:description] = value
      #end
      #
      ## These are array properties - note the splat operator
      #[ :tags, :consumes, :produces, :schemes ].each do |attr_name|
      #  define_method(attr_name) do |*value|
      #    metadata[:operation][attr_name] = value
      #  end
      #end
      #
      #def parameter(attributes)
      #  if attributes[:in] && attributes[:in].to_sym == :path
      #    attributes[:required] = true
      #  end
      #
      #  if metadata.has_key?(:operation)
      #    metadata[:operation][:parameters] ||= []
      #    metadata[:operation][:parameters] << attributes
      #  else
      #    metadata[:path_item][:parameters] ||= []
      #    metadata[:path_item][:parameters] << attributes
      #  end
      #end
      #
      #def response(code, description, metadata={}, &block)
      #  metadata[:response] = { code: code, description: description }
      #  context(description, metadata, &block)
      #end
      #
      #def schema(value)
      #  metadata[:response][:schema] = value
      #end
      #
      #def header(name, attributes)
      #  metadata[:response][:headers] ||= {}
      #  metadata[:response][:headers][name] = attributes
      #end
      #
      ## NOTE: Similar to 'description', 'examples' need to handle the case when
      ## being invoked with no params to avoid overriding 'examples' method of
      ## rspec-core ExampleGroup
      #def examples(example = nil)
      #  return super() if example.nil?
      #  metadata[:response][:examples] = example
      #end
      #
    end
  end
end
