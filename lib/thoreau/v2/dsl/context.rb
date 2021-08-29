module Thoreau
  module V2
    module DSL
      class Data
        attr_accessor :action
        attr_accessor :cases
        attr_accessor :appendix
        attr_accessor :groups

        def initialize
          @groups = []
        end
      end

      class Context

        attr_reader :data
        attr_reader :name
        attr_reader :logger

        def initialize name, logger
          @name   = name
          @logger = logger
          @data   = Data.new
        end

        def action(&block)
          logger.debug "adding action"
          @data.action = block
        end

        alias testing action
        alias subject action

        def cases(&block)
          logger.debug "adding cases"
          @data.cases = block
        end

        alias test_cases cases

        def appendix(&block)
          logger.debug "adding appendix"
          @data.appendix = block
        end

        def context
          self
        end

      end

    end
  end
end
