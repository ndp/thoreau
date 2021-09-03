require 'logger'
require 'json'
require "pstore"

module Thoreau

  class LegacyResult

  end

  class LegacyResults

    VERSION = 1

    def initialize
      super
    end

    def key_for(test_family, input)
      o = {
        kind:  test_family.kind,
        desc:  test_family.desc,
        input: input
      }
      o.to_json
    end

    def fetch(test_family, input)
      wiki = PStore.new("#{file_name}.pstore")
      wiki.transaction do
        wiki[key_for(test_family, input)]
      end
    end

    def legacy_result(test_case) end

    def file_name
      'sample-data'
    end

    def write test_family, input, result
      wiki = PStore.new("#{file_name}.pstore")
      wiki.transaction do
        wiki[key_for(test_family, input)] = result
      end
    end

  end
end
