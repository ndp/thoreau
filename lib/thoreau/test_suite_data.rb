class TestSuiteData

  attr_accessor :action_block
  attr_accessor :appendix_block
  attr_accessor :cases_block

  attr_reader :logger
  attr_reader :test_families
  attr_reader :setups

  def initialize logger
    @test_families = []
    @setups = {}
    @logger = logger
  end

  def add_setup(name, values, block)
    raise "Duplicate setup block #{name}" unless setups[name].nil?
    @setups[name.to_s] = Thoreau::Setup.new(name, values, block)
  end

  def add_test_family fam
    logger.debug "Adding test family #{fam}"
    @test_families.push fam
    fam
  end

end
