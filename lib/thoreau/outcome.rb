module Thoreau
  class Outcome

    include Thoreau::Logging

    attr_reader :output
    attr_reader :exception

    def initialize output: nil,
                   exception: nil

      if output.is_a?(Proc)
        @expected_output_proc = output
      else
        @output = output
      end
      @exception = exception
    end

    def evaluate(result, context)
      @output = context.instance_exec(result, &(@expected_output_proc)) if @expected_output_proc
    end
  end
end
