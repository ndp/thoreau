module Thoreau

  class TestFamily
    attr_reader :asserts,
                :desc,
                :expected_exception,
                :expected_output,
                :input_specs,
                :kind,
                :setups
    attr_writer :focus

    def initialize(asserts:,
                   desc:,
                   expected_exception:,
                   expected_output:,
                   failure_expected:,
                   input_specs:,
                   kind:,
                   setups:
    )
      @asserts            = asserts
      @desc               = desc
      @expected_exception = expected_exception
      @expected_output    = expected_output
      @failure_expected   = failure_expected
      @input_specs        = input_specs
      @kind               = kind
      @setups             = setups
    end

    def failure_expected?
      @failure_expected
    end

    def focused?
      @focus
    end

    def to_s
      "#{@desc||"#{@kind} #{(@input_specs.map &:to_s).to_sentence }"}"
    end

  end
end

