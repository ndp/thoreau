require 'logger'

# https://stackoverflow.com/questions/917566/ruby-share-logger-instance-among-module-classes
# The intended use is via "include":
module Thoreau
  module Logging
    class << self
      def logger
        if @logger.nil?
          @logger = Logger.new(STDOUT, formatter: proc { |severity, datetime, progname, msg|
            "#{severity}: #{msg}\n"
          })
          @logger.level = Logger::INFO
          @logger.level = Logger::DEBUG if ENV['DEBUG']
        end
        @logger
      end

      # def logger=(logger)
      #   @logger = logger
      # end
    end

    def self.included(base)
      class << base
        def logger
          Logging.logger
        end
      end
    end

    def logger
      Logging.logger
    end
  end
end
