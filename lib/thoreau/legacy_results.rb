require 'logger'
require 'json'

module Thoreau

  class LegacyResult

  end

  class LegacyResults

    VERSION = 1

    def initialize
      super
    end

    def legacy_result(test_case)

    end

    def file_name
      './sample-data.json'
    end

    def write
      File.write(file_name, JSON.dump(@data_hash))
    end

    def read
      file = File.read(file_name)
      @data_hash = JSON.parse(file)
    end

  end
end
