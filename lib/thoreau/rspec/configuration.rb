module Thoreau
  module Rspec

    class Configuration

      def initialize(rspec_config)
        @rspec_config = rspec_config
      end

      class ConfigurationError < StandardError;
      end
    end
  end
end
