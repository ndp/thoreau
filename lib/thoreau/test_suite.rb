module Thoreau
  class TestSuite

    attr_reader :name
    attr_reader :logger

    @@suites = []

    def initialize(context:, logger:, name:, focus:)
      @context = context
      @logger  = logger
      @name    = name
      @focus   = focus
      @@suites << self
      @builder = Thoreau::Case::Builder.new @context
    end

    def build_and_run
      cases = @builder.build_test_cases!

      runner = Thoreau::Case::Runner.new @context
      runner.run_test_cases! cases, @builder.skipped_count
    end

    def focused?
      @focus || @builder.any_focused?
    end

    def self.run_all!
      run_all = !@@suites.any?(&:focused?)
      @@suites.each do |suite|
        if suite.focused? || run_all
          suite.build_and_run
        else
          suite.logger.info("Suite '#{suite.name}' skipped (unfocused)")
        end
      end
    end
  end
end
