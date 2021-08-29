require 'logger'

require 'thoreau/v2/case'
require 'thoreau/v2/case_builder'
require 'thoreau/v2/case_runner'
require 'thoreau/v2/dsl/groups_support'
require 'thoreau/v2/dsl/context'
require 'thoreau/v2/dsl/groups'
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
        groups_context    = Thoreau::V2::DSL::Groups.new(@context)

        @context.instance_eval(&block)
        appendix_context.instance_eval(&@context.data.appendix) unless @context.data.appendix.nil?
        groups_context.instance_eval(&@context.data.cases) unless @context.data.cases.nil?

        builder = Thoreau::V2::CaseBuilder.new @context
        runner = Thoreau::V2::CaseRunner.new @context
        runner.run_test_cases! builder.build_test_cases!
      end

      alias suite test_suite

      include Thoreau::V2::DSL::GroupsSupport

    end

  end
end
