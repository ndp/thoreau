RSpec.describe Thoreau::SetupAssembly do

  describe '#each_setup_block' do

    cases 'when `value` is a hard-coded value'              => 'returns single value',
          'when `value` is a proc'                          => 'returns single value',
          'when `value` is block returning a value'         => 'returns single value',
          'when `value` is block returning multiple values' => 'returns multiple values',
          'when `value` is procs'                           => 'returns multiple values',
          'when `value` is an iterator'                     => 'returns multiple values',
          'when `value` is nil'                             => 'returns nil'

    setup('when `value` is a hard-coded value', 1)
    setup('when `value` is block returning a value') { 1 }
    setup('when `value` is block returning multiple values') { [1, 2, 'three'] }
    setup('when `value` is a proc') { -> (_) { 1 } }
    setup('when `value` is procs') { [-> (_) { 1 }, -> (_) { 2 }, -> (_) { 'three' }] }
    setup 'when `value` is an iterator' do
      Object.new.tap do |o|
        def o.each
          yield(1)
          yield(2)
          yield('three')
        end
      end
    end
    setup 'when `value` is nil', nil

    action do |input|
      subject = Thoreau::SetupAssembly.new('desc', input)

      # Collect and return the values yielded by #each_setup_block
      [].tap do |result|
        subject.each_setup_block { |b| result << b.call }
      end
    end

    asserts('returns single value') { |result| expect(result).to eq [1] }
    asserts('returns multiple values') { |result| expect(result).to eq [1, 2, 'three'] }
    asserts('returns nil') { |result| expect(result).to eq [nil] }

    generate!

  end
end
