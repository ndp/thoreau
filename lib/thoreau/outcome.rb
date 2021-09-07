module Thoreau
  class Outcome
    # Reprents the outcome of a given test case.
    # It can either be successful and have an `output`,
    # or it can raise an exception.
    #
    # This is used both for recording what happens to a test
    # and for representing the expectations for what will happen.
    # It is also used to save as a "snapshot" for legacy tests.

    include Thoreau::Logging

    attr_reader :output
    attr_reader :exception

    def initialize output: nil,
                   exception: nil

      if output.is_a?(Proc)
        @output_proc = output
      else
        @output = output
      end
      @exception = exception
    end

    def evaluate(result, context)
      @output = context.instance_exec(result, &(@output_proc)) if @output_proc
    end
  end
end
