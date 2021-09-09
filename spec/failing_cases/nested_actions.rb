require 'thoreau'

include Thoreau::DSL

suite 'nested actions/subjects' do
  action { 'only one action is allowed' }

  test_cases do
    action { 'no overriding! this will fail' }
    test expects: 'error on compilation'
  end
end
