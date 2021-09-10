require 'thoreau'

include Thoreau::DSL

suite 'nested subjects' do
  subject { 'only one subject is allowed' }

  test_cases do
    subject { 'no overriding! this will fail' }
    test expects: 'error on compilation'
  end
end
