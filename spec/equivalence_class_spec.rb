require_relative './spec_helper'

RSpec.describe Thoreau::EquivalenceClass do

  cases 'configured with setup and asserts' =>
          '`each_test` yields setup value, action_block and assertion',
        'configured with unknown setup'               =>
          'verify_config! returns error',
        'configured with unknown asserts'             =>
          'verify_config! returns error'

  setup 'configured with setup and asserts' do
    Thoreau::EquivalenceClass.new('setup1', 'assert1').tap do |subject|
      subject.verify_config!(
        [Thoreau::SetupAssembly.new(:setup1, [:setup_result])],
        [Thoreau::AssertionBlock.new(:assert1, -> {})])
    end
  end

  asserts '`each_test` yields setup value, action_block and assertion' do |subject|

    result = []
    subject.each_test do |setup_block, action_block, assertion|
      result << [setup_block, action_block, assertion]
    end

    expect(result.size).to eq(1)

    yielded_data = result.first
    expect(yielded_data.size).to eq(3)
    expect(yielded_data.first.call).to eq(:setup_result)
    expect(yielded_data[1]).to eq(nil)
    expect(yielded_data.last.key).to eq(:assert1)
  end

  setup "configured with unknown setup" do
    Thoreau::EquivalenceClass.new('setup1', 'assert1').
      verify_config!(
        [],
        [Thoreau::AssertionBlock.new(:assert1, -> {})])
  end

  setup "configured with unknown asserts" do
    Thoreau::EquivalenceClass.new('setup1', 'assert1').
      verify_config!(
        [Thoreau::SetupAssembly.new(:setup1, [:setup_result])],
        [])
  end

  asserts "verify_config! returns error" do |result|
    expect(result).not_to be_blank
    expect(result).to include('# WARNING:')
  end


  generate!

end
