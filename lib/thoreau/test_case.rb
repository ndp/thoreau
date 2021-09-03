require 'active_support/core_ext/module/delegation'
require_relative './case/context_builder'
require_relative './expectation'
require_relative './legacy_results'

module Thoreau
  class TestCase

    include Thoreau::Logging


    def initialize test_family:,
                   input:,
                   action_block:,
                   expectation:,
                   asserts:

      @test_family  = test_family
      @input        = input
      @action_block = action_block

      @expectation = expectation

      @assert_proc = asserts

      @ran = false
    end

    delegate :failure_expected?, to: :@test_family

    def desc
      "#{@test_family.kind}:  #{@test_family.desc} #{(@input == {} ? nil : @input.sort.to_h) || @expectation.exception || "(no args)"}"
    end

    def problem

      run unless @ran

      if @expectation.exception

        logger.debug " -> Expected Exception #{@expectation.exception} @raised_exception:#{@raised_exception}"

        if @raised_exception.to_s == @expectation.exception.to_s
          nil
        elsif @raised_exception.nil?
          "Expected exception, but none raised"
        elsif @raised_exception.is_a?(NameError)
          "Did you forget to define an input? Error: #{@raised_exception}"
        else
          "Expected '#{@expectation.exception}' exception, but raised '#{@raised_exception}' (#{@raised_exception.class.name})"
        end

      elsif @assert_proc

        logger.debug " -> Assert Proc result=#{@assert_result}"

        @assert_result ? nil : "Assertion failed. (got #{@assert_result})"
      else

        logger.debug " -> Result expected: result=#{@result} expected_output: #{@expectation.output} @raised_exception:#{@raised_exception}"

        if @raised_exception
          "Expected output, but raised exception '#{@raised_exception}'"
        elsif @expectation.output != @result
          "Expected '#{@expectation.output}', but got '#{@result}'"
        else
          nil
        end
      end
    end

    def ok?
      failure_expected? ^ !!problem.nil?
    end

    def failed?
      !ok?
    end

    def run
      logger.debug "## RUN #{desc}"
      context_builder = Case::ContextBuilder.new(input: @input)
      context         = context_builder.create_context
      begin
        # Only capture exceptions around the action itself.
        @result = context.instance_exec(&(@action_block))
      rescue Exception => e
        @raised_exception = e
        return
      ensure
        @ran = true
      end

      @expectation.evaluate(@result, context)
      @assert_result = context.instance_exec(@result, &(@assert_proc)) if @assert_proc
    end

  end
end
