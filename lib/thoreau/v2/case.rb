require 'active_support/core_ext/module/delegation'
require_relative './case_context_builder'

module Thoreau
  module V2
    class Case
      def initialize group:,
                     input:,
                     action:,
                     expected_output:,
                     expected_exception:,
                     asserts:,
                     logger:,
                     suite_context:
        @group              = group
        @input              = input
        @action             = action
        @expected_output    = expected_output
        @expected_exception = expected_exception
        @asserts            = asserts
        @logger             = logger
        @suite_context      = suite_context
        @ran                = false
      end

      delegate :failure_expected?, to: :@group

      def desc
        "#{@group.kind}:  #{@group.desc} #{(@input == {} ? nil : @input) || @expected_exception || "(no arguments here)"}"
      end

      def problem
        run unless @ran
        if @expected_exception
          if @raised_exception.to_s == @expected_exception.to_s
            nil
          elsif @raised_exception.nil?
            "Expected exception, but none raised"
          elsif @raised_exception.is_a?(NameError)
            "Did you forget to define an input? Error: #{@raised_exception}"
          else
            "Expected '#{@expected_exception}' exception, but raised '#{@raised_exception}' (#{@raised_exception.class.name})"
          end
        elsif @asserts
          @assert_result ? nil : "Assertion failed. (got #{@assert_result})"
        else
          if @raised_exception
            "Expected output, but raised exception '#{@raised_exception}'"
          elsif @expected_output.is_a?(Proc)
            @post_condition_result ? nil : "Expected '#{@post_condition_result}', but got '#{@result}'"
          elsif @expected_output != @result
            "Expected '#{@expected_output}', but got '#{@result}'"
          else
            nil
          end
        end
      end

      def ok?
        problem.nil? || failure_expected?
      end

      def failed?
        !ok?
      end

      def run
        logger.debug("create_context for #{desc}")
        context_builder        = CaseContextBuilder.new(setups: @suite_context.setups, group: @group, input: @input)
        context                = context_builder.create_context

        @result                = context.instance_exec(nil, &(@action))

        @assert_result         = context.instance_exec(@result, &(@asserts)) if @asserts
        @post_condition_result = context.instance_exec(@result, &(@expected_output)) if @expected_output.is_a?(Proc)
      rescue Exception => e
        @raised_exception = e
      ensure
        @ran = true
      end

    end
  end
end
