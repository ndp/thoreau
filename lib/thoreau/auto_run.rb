require_relative './dsl'

at_exit do
  Thoreau::Model::TestSuite.run_all!
end
