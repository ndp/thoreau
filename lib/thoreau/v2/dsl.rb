require 'logger'

require 'thoreau/v2/case'
require 'thoreau/v2/case_runner'
require 'thoreau/v2/dsl/test_cases_support'
require 'thoreau/v2/dsl/context'
require 'thoreau/v2/dsl/cases'
require 'thoreau/v2/dsl/appendix'

module Thoreau
  module V2
    module DSL

      attr_reader :logger

      def test_suite name = nil, &block
        @logger       = Logger.new(STDOUT, formatter: proc { |severity, datetime, progname, msg|
          "#{severity}: #{msg}\n"
        })
        logger.level = Logger::DEBUG
        logger.level = Logger::INFO

        @context         = Thoreau::V2::DSL::Context.new(name, @logger)
        appendix_context = Thoreau::V2::DSL::Appendix.new(@context)
        cases_context    = Thoreau::V2::DSL::Cases.new(@context)

        @context.instance_eval(&block)
        appendix_context.instance_eval(&@context.data.appendix) unless @context.data.appendix.nil?
        cases_context.instance_eval(&@context.data.cases) unless @context.data.cases.nil?

        runner = Thoreau::V2::CaseRunner.new @context
        runner.run_test_cases! runner.build_test_cases!
      end

      alias suite test_suite

      include Thoreau::V2::DSL::TestCasesSupport

    end

  end
end
