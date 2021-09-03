require 'thoreau/logging'
require 'thoreau/test_suite'
require 'thoreau/test_case'
require 'thoreau/case/case_builder'
require 'thoreau/case/suite_runner'
require 'thoreau/dsl/groups_support'
require 'thoreau/dsl/suite_context'
require 'thoreau/dsl/groups'
require 'thoreau/dsl/appendix'

at_exit do
  Thoreau::TestSuite.run_all!
end

module Thoreau

  module DSL

    include Thoreau::Logging

    attr_reader :suite_data

    def test_suite name = nil, focus: false, &block

      @suite_data = TestSuiteData.new

      @context    = Thoreau::DSL::SuiteContext.new(name, @suite_data)
      @context.instance_eval(&block)

      appendix_block = @suite_data.appendix_block
      Thoreau::DSL::Appendix.new(@suite_data, &appendix_block) unless appendix_block.nil?

      cases_block = @suite_data.cases_block
      Thoreau::DSL::Groups.new(@context, &cases_block) unless cases_block.nil?

      TestSuite.new(name: name, data: @suite_data, focus: focus)
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
