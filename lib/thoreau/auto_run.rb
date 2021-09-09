require_relative './dsl'

at_exit do
  Thoreau::TestSuite.run_all!
end
