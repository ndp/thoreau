require 'logger'

require 'thoreau/test_suite'
require 'thoreau/test_case'
require 'thoreau/case/case_builder'
require 'thoreau/case/case_runner'
require 'thoreau/dsl/groups_support'
require 'thoreau/dsl/suite_context'
require 'thoreau/dsl/groups'
require 'thoreau/dsl/appendix'

at_exit do
  Thoreau::TestSuite.run_all!
end

module Thoreau
  module DSL

    attr_reader :logger

    def test_suite name = nil, focus: false, &block
      @logger      = Logger.new(STDOUT, formatter: proc { |severity, datetime, progname, msg|
        "#{severity}: #{msg}\n"
      })
      logger.level = Logger::INFO
      logger.level = Logger::DEBUG if ENV['DEBUG']

      test_suite_data = TestSuiteData.new
      @context = Thoreau::DSL::SuiteContext.new(name, test_suite_data, @logger)
      @context.instance_eval(&block)

      appendix_block = @context.data.appendix_block
      Thoreau::DSL::Appendix.new(@context, &appendix_block) unless appendix_block.nil?

      cases_block = @context.data.cases_block
      Thoreau::DSL::Groups.new(@context, &cases_block) unless cases_block.nil?

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

    include Thoreau::DSL::GroupsSupport

  end
end
