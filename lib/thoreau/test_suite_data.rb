class TestSuiteData

  attr_accessor :action_block
  attr_accessor :appendix_block
  attr_accessor :cases_block

  attr_accessor :group_specs

  attr_reader :setups

  def initialize
    @group_specs = []
    @setups = {}
  end

  def add_setup(name, values, block)
    raise "duplicate setup block #{name}" unless setups[name].nil?
    @setups[name.to_s] = Thoreau::Setup.new(name, values, block)

  end
end
