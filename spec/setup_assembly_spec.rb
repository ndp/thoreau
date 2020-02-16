RSpec.describe Thoreau::SetupAssembly do

  #describe 'identifiers' do
  #
  #  cases 'described with string' => ['`key` is symbol', '`description` is string'],
  #        'described with symbol' => ['`key` is symbol', '`description` is string']
  #
  #  setup("described with string") { 'description' }
  #  setup("described with symbol") { :description }
  #
  #  action { |input| Thoreau::SetupAssembly.new(input, 1) }
  #
  #  asserts "`key` is symbol" do |subject|
  #    expect(subject.key).to eq(:description)
  #  end
  #
  #  asserts "`description` is string" do |subject|
  #    expect(subject.description).to eq('description')
  #  end
  #
  #  generate!
  #end
  #
  #describe '#each_setup_block' do
  #
  #  cases 'when `value` is a hard-coded value'                     => 'returns single value',
  #        'when `value` is a proc'                                 => 'returns single value',
  #        'when `value` is a hash'                                 => [
  #          'assigns instance variables',
  #          'assigns properties in context'
  #        ],
  #        'when `value` is block returning a value'                => 'returns single value',
  #        'when `value` is an array of hard-coded values'          => 'returns single value',
  #        'when `value` is block returning multiple values'        => 'returns multiple values',
  #        'when `value` is an array if array of hard-coded values' => 'returns multiple values',
  #        'when `value` is procs'                                  => 'returns multiple values',
  #        'when `value` is an iterator'                            => 'returns multiple values',
  #        'when `value` is nil'                                    => 'returns nil'
  #
  #  setup('when `value` is a hard-coded value', 1)
  #  setup('when `value` is an array of hard-coded values', [1])
  #  setup('when `value` is an array if array of hard-coded values', [[1, 2, 'three']])
  #  setup('when `value` is block returning a value') { 1 }
  #  setup('when `value` is block returning multiple values') { [1, 2, 'three'] }
  #  setup('when `value` is a proc') { -> (_) { 1 } }
  #  setup('when `value` is procs') { [-> (_) { 1 }, -> (_) { 2 }, -> (_) { 'three' }] }
  #  setup 'when `value` is an iterator' do
  #    Object.new.tap do |o|
  #      def o.each
  #        yield(1)
  #        yield(2)
  #        yield('three')
  #      end
  #    end
  #  end
  #  setup 'when `value` is nil', nil
  #  setup "when `value` is a hash", i: 7
  #
  #  action do |input|
  #    subject = Thoreau::SetupAssembly.new('desc', input)
  #
  #    # Collect and return the values yielded by #each_setup_block
  #    [].tap do |result|
  #      subject.each_setup_block { |b| result << b.call }
  #    end
  #  end
  #
  #  asserts('returns single value') { |result| expect(result).to eq [1] }
  #  asserts('returns multiple values') { |result| expect(result).to eq [1, 2, 'three'] }
  #  asserts('returns nil') { |result| expect(result).to eq [nil] }
  #  asserts("assigns instance variables") { expect(@i).to eq(7) }
  #  asserts("assigns properties in context") { expect(i).to eq(7) }
  #
  #  generate!
  #
  #end
  #
  describe '#combos_of' do
    subject { Thoreau::SetupAssembly.new('desc', i: 2) }

    specify 'handles empty list' do
      expect(subject.combos_of([[]])).to eq([{}])
    end

    specify 'handles one item list' do
      expect(subject.combos_of([[[:i, 1]]])).to eq([{i: 1}])
    end

    specify 'handles top-level combos' do
      expect(subject.combos_of([[[:i, 1]], [[:j, 1]], [[:k, 1]]])).to eq([{i:1, j:2, k:3}])
    end


    specify 'handles three item list' do
      expect(subject.combos_of([[[:i, 1], [:i, 2], [:i, 3]]])).to eq([[[:i, 1]], [[:i, 2]], [[:i, 3]]])
    end

  end
  describe '#setup_blocks' do

    describe 'given a hash' do

      specify 'with one key => one value value returns one block' do
        subject = Thoreau::SetupAssembly.new('desc', i: 2)
        expect(subject.setup_blocks.size).to eq(1)
      end

      specify 'injects ivar with the name of the key' do
        subject = Thoreau::SetupAssembly.new('desc', i: 2)

        blks = subject.setup_blocks
        blks.each do |blk|
          context = Object.new
          blk.call(context)
          expect(context.instance_variable_get(:@i)).to eq(2)
        end
      end

      specify 'injects accessor fn with the name of the key' do
        subject = Thoreau::SetupAssembly.new('desc', j: 3)

        blks = subject.setup_blocks
        blks.each do |blk|
          context = Object.new
          blk.call(context)
          expect(context.j).to eq(3)
        end
      end

      specify 'does not pollute general context with specific behaviors' do
        subject = Thoreau::SetupAssembly.new('desc', i: 2)

        subject.setup_blocks.each { |blk| blk.call(Object.new) }

        expect(Object.new.respond_to?(:i)).to be_falsey
      end

      specify 'sets up multiple variables with one value' do
        subject = Thoreau::SetupAssembly.new('desc', i: 2, j: 3)

        context = Object.new
        subject.setup_blocks.each { |blk| blk.call(context) }

        expect(context.i).to eq(2)
        expect(context.j).to eq(3)
      end

      specify 'sets up one variable with multiple values' do
        subject = Thoreau::SetupAssembly.new('desc', i: [1, 2, 3])

        blks = subject.setup_blocks
        expect(blks.size).to eq(3)

        context = Object.new
        blks.first.call(context)
        expect(context.i).to eq(1)
        context = Object.new
        blks[1].call(context)
        expect(context.i).to eq(2)
        context = Object.new
        blks.last.call(context)
        expect(context.i).to eq(3)
      end

      specify 'sets up two keys, one with multiple values' do
        subject = Thoreau::SetupAssembly.new('desc', i: [1, 2, 3], b: true)

        blks = subject.setup_blocks
        expect(blks.size).to eq(3)

        context = Object.new
        blks.first.call(context)
        expect(context.i).to eq(1)
        expect(context.b).to eq(true)
        context = Object.new
        blks[1].call(context)
        expect(context.i).to eq(2)
        expect(context.b).to eq(true)
        context = Object.new
        blks.last.call(context)
        expect(context.i).to eq(3)
        expect(context.b).to eq(true)
      end

      specify 'sets up two keys, each with multiple values' do
        subject = Thoreau::SetupAssembly.new('desc', i: [1, 2], b: [true, false])

        blks = subject.setup_blocks
        expect(blks.size).to eq(4)

        context = Object.new
        blks.first.call(context)
        expect(context.i).to eq(1)
        context = Object.new
        blks[1].call(context)
        expect(context.i).to eq(2)
        context = Object.new
        blks.last.call(context)
        expect(context.i).to eq(3)
      end
    end
  end

end
