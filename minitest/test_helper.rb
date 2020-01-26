$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/pride'

require 'thoreau/minitest'

# TODO This pollutes the global namespace. Where should it be included?
include Thoreau::Minitest::DSL

