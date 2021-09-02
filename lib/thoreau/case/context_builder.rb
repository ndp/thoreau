module Thoreau
  module Case
    class ContextBuilder

      def initialize(group:, input:)
        @group        = group
        @input        = input
      end

      def create_context
        temp_class   = Class.new
        temp_context = temp_class.new
        inject_hash_into_context(@input, temp_context)
        temp_context
      end

      private

      def inject_hash_into_context(h, temp_context)
        h.each do |lval, rval|
          temp_context.instance_variable_set("@#{lval}", rval)
          temp_context.class.attr_accessor lval
        end
      end

    end
  end
end
