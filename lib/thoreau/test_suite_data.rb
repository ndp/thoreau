class TestSuiteData

  attr_accessor :action_block
  attr_accessor :appendix_block
  attr_accessor :cases_block

  attr_accessor :group_specs

  def initialize
    @group_specs = []
  end
end
