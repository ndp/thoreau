module Thoreau
  class TestSuiteData

    include Thoreau::Logging

    attr_accessor :action_block
    attr_accessor :appendix_block
    attr_accessor :cases_block

    attr_reader :test_families
    attr_reader :setups

    def initialize
      @test_families = []
      @setups        = {}
    end

    def add_setup(name, values, block)
      raise "Duplicate setup block #{name}" unless setups[name].nil?
      logger.debug "Adding setup block #{name}"
      @setups[name.to_s] = Thoreau::Setup.new(name, values, block)
    end

    def add_test_family fam
      logger.debug "Adding test family #{fam}"
      @test_families.push fam
      fam
    end

  end
end
