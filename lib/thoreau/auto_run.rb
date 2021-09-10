require_relative './dsl'

at_exit do
  Thoreau::Models::TestSuite.run_all!
end
