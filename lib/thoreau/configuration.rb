module Thoreau
  class Configuration
    attr_accessor :legacy_outcome_path

    def initialize
      @legacy_outcome_path = './tmp/legacy-outcomes.pstore'
    end
  end
end
