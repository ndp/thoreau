require 'logger'

require 'thoreau/v2/case'
require 'thoreau/v2/case_builder'
require 'thoreau/v2/case_runner'
require 'thoreau/v2/dsl/groups_support'
require 'thoreau/v2/dsl/context'
require 'thoreau/v2/dsl/groups'
require 'thoreau/v2/dsl/appendix'

at_exit do
  Thoreau::V2::TestSuite.run_all!
end

module Thoreau
  module V2

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
      end

      def build_and_run
        builder = Thoreau::V2::CaseBuilder.new @context
        runner  = Thoreau::V2::CaseRunner.new @context
        runner.run_test_cases! builder.build_test_cases!
      end

      def focused?
        @focus
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

    module DSL

      attr_reader :logger

      def test_suite name = nil, focus: false, &block
        @logger      = Logger.new(STDOUT, formatter: proc { |severity, datetime, progname, msg|
          "#{severity}: #{msg}\n"
        })
        logger.level = Logger::DEBUG
        logger.level = Logger::INFO

        @context = Thoreau::V2::DSL::Context.new(name, @logger)

        appendix_context = Thoreau::V2::DSL::Appendix.new(@context)
        groups_context   = Thoreau::V2::DSL::Groups.new(@context)

        @context.instance_eval(&block)
        appendix_context.instance_eval(&@context.data.appendix) unless @context.data.appendix.nil?
        groups_context.instance_eval(&@context.data.cases) unless @context.data.cases.nil?

        TestSuite.new(context: @context, focus: focus, logger: logger, name: name)
      end

      def xtest_suite name = nil, &block
      end

      alias suite test_suite
      alias xsuite xtest_suite

      def test_suite! name = nil, &block
        test_suite name, focus: true, &block
      end
      alias suite! test_suite!

      include Thoreau::V2::DSL::GroupsSupport

    end

  end
end
