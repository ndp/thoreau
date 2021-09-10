require 'active_support/core_ext/module/delegation'
require_relative '../case/context_builder'
require_relative './outcome'
require_relative '../service/legacy_expected_outcomes'

module Thoreau
  module Model
    class TestCase

      include Thoreau::Logging

      attr_reader :actual, :family_desc, :input
      attr_accessor :expectation

      def initialize family_desc:,
                     input:,
                     action_block:,
                     expectation:,
                     asserts:,
                     negativo:

        @family_desc  = family_desc
        @input        = input
        @action_block = action_block
        @negativo     = negativo

        @expectation = expectation

        @assert_proc = asserts

        @ran = false
      end

      def failure_expected?
        @negativo
      end

      def desc
        "#{@family_desc} #{(@input == {} ? nil : @input.sort.to_h) || @expectation.exception || "(no args)"}"
      end

      def problem

        run unless @ran

        if @expectation.exception

          logger.debug " -> Expected Exception #{@expectation.exception} @actual.exception:#{@actual.exception}"

          if @actual.exception.to_s == @expectation.exception.to_s
            nil
          elsif @actual.exception.nil?
            "Expected exception, but none raised"
          elsif @actual.exception.is_a?(NameError)
            "Did you forget to define an input? Error: #{@actual.exception}"
          else
            "Expected '#{@expectation.exception}' exception, but raised '#{@actual.exception}' (#{@actual.exception.class.name})"
          end

        elsif @assert_proc

          logger.debug " -> Assert Proc result=#{@assert_result}"

          @assert_result ? nil : "Assertion failed. (got #{@assert_result})"
        else

          logger.debug " -> Result expected: result=#{@actual.output} expected_output: #{@expectation.output} @actual.exception:#{@actual.exception}"

          if @actual.exception
            "Expected output, but raised exception '#{@actual.exception}'"
          elsif @expectation.output != @actual.output
            "Expected '#{@expectation.output}', but got '#{@actual.output}'"
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
          # Only capture exceptions around the subject itself.
          output  = context.instance_exec(&(@action_block))
          @actual = Model::Outcome.new output: output
        rescue Exception => e
          logger.debug("** Exception: #{e.class.name} #{e}")
          logger.debug("Available local variables: #{@input.keys.empty? ? '(none)' : @input.keys.to_sentence}") if e.is_a? NameError
          @actual = Model::Outcome.new exception: e
          return
        ensure
          @ran = true
        end

        @expectation.evaluate(@actual.output, context) unless @expectation == :use_legacy_snapshot
        @assert_result = context.instance_exec(@actual.output, &(@assert_proc)) if @assert_proc
      end

    end
  end
end
