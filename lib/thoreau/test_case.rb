require 'active_support/core_ext/module/delegation'
require_relative './case/context_builder'
require_relative './legacy_results'

module Thoreau
  class TestCase

    include Thoreau::Logging

    def initialize test_family:,
                   input:,
                   action_block:,
                   expected_output:,
                   expected_exception:,
                   asserts:

      @test_family  = test_family
      @input  = input
      @action_block = action_block
      if expected_output.is_a?(Proc)
        @expected_output_proc = expected_output
      elsif expected_output == :legacy
        @expected_legacy_output = LegacyResults.new.fetch(test_family, input)
      else
        @expected_output = expected_output
      end
      @expected_exception = expected_exception
      @assert_proc        = asserts
      @ran                = false
    end

    delegate :failure_expected?, to: :@test_family

    def desc
      "#{@test_family.kind}:  #{@test_family.desc} #{(@input == {} ? nil : @input.sort.to_h) || @expected_exception || "(no args)"}"
    end

    def problem

      run unless @ran

      if @expected_exception

        logger.debug " -> Expected Exception #{@expected_exception} @raised_exception:#{@raised_exception}"

        if @raised_exception.to_s == @expected_exception.to_s
          nil
        elsif @raised_exception.nil?
          "Expected exception, but none raised"
        elsif @raised_exception.is_a?(NameError)
          "Did you forget to define an input? Error: #{@raised_exception}"
        else
          "Expected '#{@expected_exception}' exception, but raised '#{@raised_exception}' (#{@raised_exception.class.name})"
        end

      elsif @assert_proc

        logger.debug " -> Assert Proc result=#{@assert_result}"

        @assert_result ? nil : "Assertion failed. (got #{@assert_result})"
      else

        logger.debug " -> Result expected: result=#{@result} @expected_output: #{@expected_output} @raised_exception:#{@raised_exception}"

        if @raised_exception
          "Expected output, but raised exception '#{@raised_exception}'"
        elsif @expected_output != @result
          "Expected '#{@expected_output}', but got '#{@result}'"
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

      @assert_result   = context.instance_exec(@result, &(@assert_proc)) if @assert_proc
      @expected_output = context.instance_exec(@result, &(@expected_output_proc)) if @expected_output_proc
    end

  end
end
