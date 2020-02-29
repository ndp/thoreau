require_relative './test_helper'

describe Thoreau::SetupAssembler do

  thoreau do

    cases 'single hard-coded value' => 'returns value',
          'hard-coded values'       => 'returns values',
          'single proc'             => 'returns value',
          'procs'                   => 'returns values',
          'generator'               => 'returns values',
          'nil'                     => 'returns nil'

    setup('single hard-coded value') { 1 }
    setup('hard-coded values') { [1, 2, 'three'] }
    setup('single proc') { -> (_) { 1 } }
    setup('procs') { [-> (_) { 1 }, -> (_) { 2 }, -> (_) { 'three' }] }
    setup 'generator' do
      Object.new.tap do |o|
        def o.each
          yield(1)
          yield(2)
          yield('three')
        end
      end
    end
    setup 'nil', nil

    action do |input|
      subject = Thoreau::SetupAssembler.new('desc', input)
      [].tap do |result|
        subject.each_setup_block { |b| result << b.call }
      end
    end

    asserts('returns value') { |result| _(result).must_be :==, [1] }
    asserts('returns values') { |result| _(result).must_be :==, [1, 2, 'three'] }
    asserts('returns nil') { |result| _(result).must_be :==, [nil] }

  end
end
