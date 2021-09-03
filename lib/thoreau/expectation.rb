module Thoreau
  class Expectation

    include Thoreau::Logging

    attr_reader :output
    attr_reader :exception

    def initialize output:,
                   exception:

      if output.is_a?(Proc)
        @expected_output_proc = output
      elsif output == :legacy
        @legacy_output = nil #LegacyResults.new.fetch(test_family, input)
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
