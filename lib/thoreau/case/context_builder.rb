module Thoreau
  class Case
    class ContextBuilder

      def initialize(setups:, group:, input:)
        @suite_setups = setups
        @group        = group
        @input        = input
      end

      def create_context
        temp_class   = Class.new
        temp_context = temp_class.new

        @group.setups.each do |setup_key|
          exec_setup(setup_key, temp_context)
        end

        inject_hash_into_context(@input, temp_context)
        temp_context
      end

      private

      def exec_setup(setup_key, temp_context)
        setup = @suite_setups[setup_key.to_s]
        logger.error "Unrecognized setup context '#{setup_key}'. Available: #{@suite_setups.keys.join(' ')}" if setup.nil?
        values = setup.first || {}
        inject_hash_into_context(values, temp_context)

        block = setup[1]
        return if block.nil?

        result = temp_context.instance_eval(&block)
        inject_hash_into_context(result, temp_context) if result.is_a?(Hash)
      end

      def inject_hash_into_context(h, temp_context)
        h.each do |lval, rval|
          temp_context.instance_variable_set("@#{lval}", rval)
          temp_context.class.attr_accessor lval
        end
      end

    end
  end
end
