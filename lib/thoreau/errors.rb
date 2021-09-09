module Thoreau
  class TestCasesAtMultipleLevelsError < RuntimeError
    def initialize(msg = nil)
      super "Test cases must be specified either at the top level or inside test_cases blocks, but not both!"
    end
  end

  class OverriddenActionError < RuntimeError
    def initialize(msg = nil)
      super "Extra action/subject provided for tests. Actions/subjects must be specified EITHER in the `suite` or within `test_cases` (not both)."
    end
  end


end
