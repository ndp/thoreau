require 'thoreau/auto_run'
include Thoreau::DSL

suite "Addition regression" do
  subject { 1 + 1 }
  spec output: 2
  spec output: 3 # just to see what error detection looks like
end
