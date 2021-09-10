module Thoreau
  module Model
    class Appendix

      attr_reader :setups

      def initialize setups: {}
        @setups = setups
      end

      def add_setup setup
        raise "Duplicate setup block #{setup.name}" unless setups[setup.name].nil?
        @setups[setup.name] = setup
      end

      def setup_values keys
        keys
          .map { |key| self.setup_key_to_inputs key }
          .reduce(Hash.new) { |m, h| m.merge(h) }
      end

      private

      def setup_key_to_inputs key
        setup = self.setups[key.to_s]
        raise "Unrecognized setup context '#{key}'. Available: #{self.setups.keys.to_sentence}" if setup.nil?
        logger.debug("   setup_key_to_inputs `#{key}`: #{setup}")
        return setup.values if setup.block.nil?

        result = Class.new.new.instance_eval(&setup.block)
        logger.error "Setup #{key} did not return a hash object" unless result.is_a?(Hash)
        result
      end

    end
  end
end
