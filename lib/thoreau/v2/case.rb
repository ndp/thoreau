module Thoreau
  module V2
    class Case
      def initialize kind, input, action, expected_output, expected_exception
        @kind               = kind
        @input              = input
        @action             = action
        @expected_output    = expected_output
        @expected_exception = expected_exception
        @ran                = false
      end

      def desc
        "#{@kind}:  #{(@input == {} ? nil : @input) || @expected_exception}"
      end

      def problem
        run unless @ran
        if @expected_exception
          if @raised_exception.to_s == @expected_exception.to_s
            nil
          elsif @raised_exception.nil?
            "Expected exception, but none raised"
          else
            "Expected #{@raised_exception} exception, but raised #{@expected_exception}"
          end
        else
          if @raised_exception
            "Expected output, but raised exception #{@raised_exception}"
          elsif @expected_output != @result
            "Expected '#{@expected_output}', but got '#{@result}'"
          else
            nil
          end
        end
      end

      def success?
        problem.nil?
      end

      def failed?
        !success?
      end

      def run
        @result      = create_context.instance_exec(nil, &(@action))
      rescue Exception => e
        @raised_exception = e
      ensure
        @ran = true
      end

      def create_context
        temp_context = Class.new.new
        @input.each do |lval, rval|
          temp_context.instance_variable_set("@#{lval}", rval)
          temp_context.class.attr_accessor lval
        end
        temp_context
      end
    end

  end
end
