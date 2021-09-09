module Thoreau
  module Models

    class Setup

      attr_reader :name, :values, :block

      def initialize name, values, block
        @name   = name.to_s
        @values = values
        # @value = [values].flatten unless values.nil?
        @block = block
      end

    end
  end
end
