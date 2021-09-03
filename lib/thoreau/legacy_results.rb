require 'logger'
require 'json'
require "pstore"

module Thoreau

  class LegacyResult

  end

  class LegacyResults

    VERSION = 1

    def initialize(suite_name)
      @suite_name = suite_name
    end

    def key_for(test_case)
      o = {
        desc:  test_case.family_desc,
        input: test_case.input
      }
      o.to_json
    end

    def has_saved_legacy_expectation? test_case
      logger.debug("Looking for saved expectations for #{key_for(test_case)}")
      !!(load_legacy_expectation test_case)
    end

    def load_legacy_expectation test_case
      wiki = PStore.new("#{file_name}.pstore")
      wiki.transaction do
        wiki[key_for(test_case)]
      end
    end

    def save_legacy_expectation test_case
      wiki = PStore.new("#{file_name}.pstore")
      wiki.transaction do
        wiki[key_for(test_case)] = test_case.actual
      end
    end

    private

    def file_name
      'sample-data'
    end

  end
end
