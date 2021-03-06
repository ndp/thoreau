RSpec.describe Thoreau::SetupAssembler do

  describe 'description' do

    cases 'initalized with string' => ['`.key` is symbol', '`.description` is string'],
          'initalized with symbol' => ['`.key` is symbol', '`.description` is string']

    setup('initalized with string', 'a string')
    setup('initalized with symbol', :'a string')

    action { |input| Thoreau::SetupAssembler.new(input, 1) }

    asserts '`.key` is symbol' do |subject, result|
      expect(subject.key).to eq(:'a string')
    end

    asserts '`.description` is string' do |subject|
      expect(subject.description).to eq('a string')
    end

    generate!
  end

  describe '#setup_blocks' do

    cases 'when `value` is a hard-coded value'                     => 'returns single value',
          'when `value` is a proc'                                 => 'returns single value',
          'when `value` is a hash'                                 => [
            'assigns instance variables',
            'assigns properties in context'
          ],
          'when `value` is block returning a value'                => 'returns single value',
          'when `value` is an array of hard-coded values'          => 'returns single value',
          'when `value` is block returning multiple values'        => 'returns multiple values',
          'when `value` is an array of array of hard-coded values' => 'returns multiple values',
          #'when `value` is an iterator returning multiple values'  => 'returns multiple values',
          'when `value` is nil' => 'returns nil'

    setup('when `value` is a hard-coded value', 1)
    setup('when `value` is an array of hard-coded values', [1])
    setup('when `value` is an array of array of hard-coded values', [[1, 2, 'three']])
    setup('when `value` is block returning a value') { 1 }
    setup('when `value` is block returning multiple values') { [1, 2, 'three'] }
    setup('when `value` is a proc', -> (_) { 1 })
    #setup 'when `value` is an iterator returning multiple values' do
    #  Object.new.tap do |o|
    #    def o.each
    #      yield(1)
    #      yield(2)
    #      yield('three')
    #    end
    #  end
    #end
    setup 'when `value` is nil', nil
    setup 'when `value` is a hash', foo: 7

    #action do |value|
    #  subject = Thoreau::SetupAssembly.new('desc', value)
    #  result = subject.setup_blocks.first.call(Object.new)
    #  result.respond_to?(:fetch) ? result.fetch(:input, result) : result
    #end

    asserts('returns single value') { |result| expect(result).to eq 1 }
    asserts('returns multiple values') { |result| expect(result).to eq [1, 2, 'three'] }
    asserts('returns nil') { |result| expect(result).to eq nil }
    asserts('assigns instance variables') { expect(@foo).to eq(7) }
    asserts('assigns properties in context') { expect(foo).to eq(7) }

    generate!

  end

  describe '#combos_of' do
    subject { Thoreau::SetupAssembler.new('desc', i: 2) }

    specify 'handles empty list' do
      expect(subject.combos_of([])).to eq([{}])
    end

    specify 'handles one item list' do
      expect(subject.combos_of([[[:i, 1]]])).to eq([{ i: 1 }])
    end

    specify 'creates map of distinct combos' do
      expect(subject.combos_of([[[:i, 1]], [[:j, 2]], [[:k, 3]]])).to eq([{ i: 1, j: 2, k: 3 }])
    end


    specify 'create three maps for three values' do
      expect(subject.combos_of([[[:i, 1], [:i, 2], [:i, 3]]])).to eq([{ i: 1 }, { i: 2 }, { i: 3 }])
    end

    specify 'create combinations of values' do
      expect(subject.combos_of([[[:i, 1], [:i, 2]], [[:j, 3], [:j, 4]]])).
        to eq([{ i: 1, j: 3 }, { i: 1, j: 4 }, { i: 2, j: 3 }, { i: 2, j: 4 }])
    end

  end
  describe '#setup_blocks' do

    # single value: 1, "foo"
    # multiple values in one spec: i: 1, j: 2 -- desc (i=2 j=3)
    # multiple setups: [1, 2]
    # combinations of values:  i: [1, 2, 3], b: true

    describe 'given single harded-coded value' do

      specify 'exposes single value as `input`' do
        subject = Thoreau::SetupAssembler.new('desc', 2)

        setup_blocks = subject.setup_blocks
        expect(setup_blocks.size).to eq(1)

        context = Object.new
        setup_blocks.each { |blk| blk.call(context) }

        expect(context.input).to eq 2
      end
    end

    describe 'given an array of harded-coded values' do

      #            'when `value` is an array of hard-coded values'          => 'returns single value',
      specify 'generates a setup for each value' do
        subject = Thoreau::SetupAssembler.new('desc', [1, 2, 'three'])

        setup_blocks = subject.setup_blocks
        expect(setup_blocks.size).to eq(3)

        context = Object.new
        setup_blocks[0].call(context)
        expect(context.input).to eq 1
        setup_blocks[1].call(context)
        expect(context.input).to eq 2
        setup_blocks[2].call(context)
        expect(context.input).to eq 'three'
      end

    end


    describe 'given a hash with one key' do

      specify '`description` has value in it' do
        subject = Thoreau::SetupAssembler.new('desc', input: 2)

        subject.setup_blocks.each do |blk|
          expect(blk.description).to eq('desc (2)')
        end
      end

      specify '`description` has a named variable and value in it' do
        subject = Thoreau::SetupAssembler.new('desc', i: 2)

        subject.setup_blocks.each do |blk|
          expect(blk.description).to eq('desc (i=2)')
        end
      end

      specify 'creates one block' do
        subject = Thoreau::SetupAssembler.new('desc', i: 2)
        expect(subject.setup_blocks.size).to eq(1)
      end

      specify 'block injects ivar with the name of the key' do
        subject = Thoreau::SetupAssembler.new('desc', i: 2)

        blks = subject.setup_blocks
        blks.each do |blk|
          context = Object.new
          blk.call(context)
          expect(context.instance_variable_get(:@i)).to eq(2)
        end
      end

      specify 'block injects accessor fn with the name of the key' do
        subject = Thoreau::SetupAssembler.new('desc', j: 3)

        subject.setup_blocks.each do |blk|
          context = Object.new
          blk.call(context)
          expect(context.j).to eq(3)
        end
      end

      specify 'block raises if accessor function is already defined' do
        subject = Thoreau::SetupAssembler.new('desc', j: 3)

        subject.setup_blocks.each do |blk|
          context = Object.new

          def context.j;
          end

          expect {
            blk.call(context)
          }.to raise_exception('`j` is already defined in the context. This will be confusing.')
        end
      end

      specify 'block does not pollute general context with specific behaviors' do
        subject = Thoreau::SetupAssembler.new('desc', i: 2)

        subject.setup_blocks.each { |blk| blk.call(Object.new) }

        expect(Object.new.respond_to?(:i)).to be_falsey
      end

      specify 'sets up multiple variables with one value' do
        subject = Thoreau::SetupAssembler.new('desc', i: 2, j: 3)

        context = Object.new
        subject.setup_blocks.each { |blk| blk.call(context) }

        expect(context.i).to eq(2)
        expect(context.j).to eq(3)
      end

      specify 'creates description with multiple variables in it' do
        subject = Thoreau::SetupAssembler.new('desc', i: 2, j: 3)

        subject.setup_blocks.each do |blk|
          expect(blk.description).to eq('desc (i=2 j=3)')
        end
      end

      specify 'sets up one variable with multiple values' do
        subject = Thoreau::SetupAssembler.new('desc', i: [1, 2, 3])

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
        subject = Thoreau::SetupAssembler.new('desc', i: [1, 2, 3], b: true)

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
        subject = Thoreau::SetupAssembler.new('desc', i: [1, 2], b: [true, false])

        blks = subject.setup_blocks
        expect(blks.size).to eq(4)

        context = Object.new
        blks.first.call(context)
        expect(context.i).to eq(1)
        expect(context.b).to eq(true)
        context = Object.new
        blks[1].call(context)
        expect(context.i).to eq(1)
        expect(context.b).to eq(false)
        context = Object.new
        blks.last.call(context)
        expect(context.i).to eq(2)
      end
    end

    # 'when `value` is a hard-coded value'                     => 'returns single value',
    describe 'blocks & procs' do

      specify 'describes with given name' do
        subject = Thoreau::SetupAssembler.new('desc') do
          2
        end

        expect(subject.description).to eq('desc')
      end

      #'when `value` is block returning a value'                => 'returns single value',
      specify 'when block returns a value, exposes single value as `input`' do
        subject = Thoreau::SetupAssembler.new('desc') do
          2
        end

        setup_blocks = subject.setup_blocks
        expect(setup_blocks.size).to eq(1)

        context = Object.new
        setup_blocks.each { |blk| blk.call(context) }

        expect(context.input).to eq 2
      end

      #'when `value` is block returning multiple values'        => 'returns multiple values',
      specify 'when block returns an enumerable, exposes single value as `input`' do
        subject = Thoreau::SetupAssembler.new('desc') do
          [1, 2, 3]
        end

        setup_blocks = subject.setup_blocks
        expect(setup_blocks.size).to eq(1)

        context = Object.new
        setup_blocks.first.call(context)
        expect(context.input).to eq [1, 2, 3]
      end

      #'when `value` is a proc'                                 => 'returns single value',
      specify 'when proc, exposes single value as `input`' do
        subject = Thoreau::SetupAssembler.new('desc', -> (_) { 2 })

        context = Object.new
        subject.setup_blocks.each { |blk| blk.call(context) }

        expect(context.input).to eq 2
      end

      ##'when `value` is procs'                                  => 'returns multiple values',
      #specify 'when multiple procs, exposes multple values as `input`' do
      #  subject = Thoreau::SetupAssembly.new('desc', [-> (_) { 1 }, -> (_) { 2 }, -> (_) { 'three' }])
      #
      #  setup_blocks = subject.setup_blocks
      #  expect(setup_blocks.size).to eq(3)
      #
      #  context = Object.new
      #  setup_blocks.each { |blk| blk.call(context) }
      #
      #  expect(context.input).to eq [1, 2, 'three']
      #end

      # 'when `value` is an iterator'                            => 'returns multiple values',
      specify 'when `value` is an iterator, exposes values individually as `input`' do
        iter    = Object.new.tap do |o|
          def o.each
            yield(1)
            yield(2)
            yield('three')
          end
        end
        subject = Thoreau::SetupAssembler.new('desc', iter)

        setup_blocks = subject.setup_blocks
        expect(setup_blocks.size).to eq(3)

        context = Object.new
        subject.setup_blocks.each { |blk| blk.call(context) }

        expect(context.input).to eq 'three'
      end
    end

    # describe 'multple' do
    #   specify 'should run both setups' do
    #     subject = Thoreau::SetupAssembly.new('desc', [{i:1}, {j: 2}])
    #
    #     setup_blocks = subject.setup_blocks
    #     expect(setup_blocks.size).to eq(1)
    #
    #     context = Object.new
    #     subject.setup_blocks.each { |blk| blk.call(context) }
    #
    #     expect(context.i).to eq 1
    #     expect(context.j).to eq 2
    #   end
    # end
  end

end
