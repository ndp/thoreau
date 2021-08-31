require 'active_support/core_ext/module/delegation'
require_relative './case/context_builder'

module Thoreau
  class Case
    def initialize group:,
                   input:,
                   action:,
                   expected_output:,
                   expected_exception:,
                   asserts:,
                   logger:,
                   suite_context:
      @group  = group
      @input  = input
      @action = action
      if expected_output.is_a?(Proc)
        @expected_output_proc = expected_output
      else
        @expected_output = expected_output
      end
      @expected_exception = expected_exception
      @assert_proc        = asserts
      @logger             = logger
      @suite_context      = suite_context
      @ran                = false
    end

    delegate :failure_expected?, to: :@group

    def desc
      "#{@group.kind}:  #{@group.desc} #{(@input == {} ? nil : @input.sort.to_h) || @expected_exception || "(no args)"}"
    end

    def problem
      run unless @ran
      if @expected_exception

        logger.debug " -> @expected_exception:#{@expected_exception} @raised_exception:#{@raised_exception}"

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

        logger.debug " -> @assert_result: #{@assert_result}"

        @assert_result ? nil : "Assertion failed. (got #{@assert_result})"
      else

        logger.debug " -> @result: #{@result} @expected_output: #{@expected_output} @raised_exception:#{@raised_exception}"

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
      logger.debug("create_context for #{desc} -> ")
      context_builder = Case::ContextBuilder.new(setups: @suite_context.setups, group: @group, input: @input)
      context         = context_builder.create_context
      begin
        # Only capture exceptions around the action itself.
        @result = context.instance_exec(&(@action))
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
