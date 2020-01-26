module Thoreau
  module Rspec

    class Configuration

      def initialize(rspec_config)
        @rspec_config = rspec_config
      end

      #def swagger_root
      #  @swagger_root ||= begin
      #                      if @rspec_config.swagger_root.nil?
      #                        raise ConfigurationError, 'No swagger_root provided. See swagger_helper.rb'
      #                      end
      #                      @rspec_config.swagger_root
      #                    end
      #end

      class ConfigurationError < StandardError;
      end
    end
  end
end
