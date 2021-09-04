require 'logger'
require 'json'
require "pstore"

module Thoreau

  class LegacyExpectedOutcomes

    # A simple store of expected outcomes of test cases.
    #
    # They are stored in a "pstore" database, with the test descriptor
    # and inputs being the key. If you change the input of the test, it
    # should generate a new saved result.
    #
    # Set ENV['RESET_SNAPSHOTS'] to, well, reset all the snapshots.

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

    def has_saved_for? test_case
      logger.debug("Looking for saved expectations for #{key_for(test_case)}")
      !!(load_for test_case)
    end

    def load_for test_case
      wiki = PStore.new("#{file_name}.pstore")
      wiki.transaction do
        wiki[key_for(test_case)]
      end
    end

    def save! test_case
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
