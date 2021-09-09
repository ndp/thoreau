require 'thoreau'

include Thoreau::DSL


suite 'nested tests' do
  subject { 'only one' }

  test 'simple test', expects: 'only one'

  test_cases do
    test expects: 'error on compilation'
  end
end
