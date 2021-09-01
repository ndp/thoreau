module Thoreau

  class SpecGroup
    attr_reader :asserts,
                :desc,
                :expected_exception,
                :expected_output,
                :input_specs,
                :kind,
                :legacy,
                :setups
    attr_writer :focus

    def initialize(asserts:,
                   desc:,
                   expected_exception:,
                   expected_output:,
                   failure_expected:,
                   input_specs:,
                   legacy:,
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
      @legacy             = legacy
      @setups             = setups
    end

    def failure_expected?
      @failure_expected
    end

    def focused?
      @focus
    end

  end
end

