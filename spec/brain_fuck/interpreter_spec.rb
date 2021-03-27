require 'brain_fuck'
require_relative '../../lib/brain_fuck/interpreter'

RSpec.describe BrainFuck::Interpreter do
  it 'can construct and inject a processor' do
    processor = BrainFuck::Processor.new('abc', [0, 0, 0])
    i = BrainFuck::Interpreter.new(processor)
    expect(i.processor).to eq processor
  end

  it 'command ; (input integer) raises error' do
    processor = BrainFuck::Processor.new(';', [0, 0, 0])
    i = BrainFuck::Interpreter.new(processor)
    expect { i.run }.to raise_error BrainFuck::Error
  end

  it '#step advances the code_ptr' do
    processor = BrainFuck::Processor.new('a', [0])
    i = BrainFuck::Interpreter.new(processor)

    i.run

    expect(processor.finished?).to eq true
  end

  it '+ (increment_data) command increases the current data value by 1' do
    processor = BrainFuck::Processor.new('+', [0])
    i = BrainFuck::Interpreter.new(processor)

    i.run

    expect(processor.get).to eq 1
  end

  it '- (decrement_data) decreases the data value by 1' do
    processor = BrainFuck::Processor.new('-', [1])
    i = BrainFuck::Interpreter.new(processor)

    i.run

    expect(processor.get).to eq 0
  end

  it 'the > (advance_data_ptr) command increases the data pointer by 1' do
    processor = BrainFuck::Processor.new('>', [0, 1])
    i = BrainFuck::Interpreter.new(processor)

    i.run

    expect(processor.get).to eq 1
  end

  it '< (step_back_data_ptr) command decreases the data pointer by 1' do
    processor = BrainFuck::Processor.new('><', [0, 1])
    i = BrainFuck::Interpreter.new(processor)

    i.run

    expect(processor.get).to eq 0
  end

  it '. (output) command outputs the current data value as a char' do
    processor = BrainFuck::Processor.new('.', [65])
    output = StringIO.new
    i = BrainFuck::Interpreter.new(processor, $stdin, output)

    i.run

    expect(output.string).to eq 'A'
  end

  it 'the , (input) command inputs a char as integer' do
    processor = BrainFuck::Processor.new(',', [0])
    input = StringIO.new('A')
    i = BrainFuck::Interpreter.new(processor, input)

    i.run

    expect(processor.get).to eq 65
  end

  it 'the : comman outputs the data value as integer' do
    processor = BrainFuck::Processor.new(':', [123])
    output = StringIO.new
    i = BrainFuck::Interpreter.new(processor, $stdin, output)

    i.run

    expect(output.string).to eq '123 '
  end

  describe 'igores unknown instructions' do
    it 'moves code pointer to next instruction' do
      processor = BrainFuck::Processor.new('Q', [0])
      i = BrainFuck::Interpreter.new(processor)

      i.run

      expect(processor.finished?).to eq true
    end

    it 'does not change the data' do
      processor = BrainFuck::Processor.new('Q', [0])
      i = BrainFuck::Interpreter.new(processor)

      i.run

      expect(processor.get).to eq 0
    end
  end

  describe 'loops' do
    it 'loops until data is zero' do
      processor = BrainFuck::Processor.new('[:-]:', [3])
      output = StringIO.new
      i = BrainFuck::Interpreter.new(processor, $stdin, output)

      i.run

      expect(output.string).to eq '3 2 1 0 '
    end

    it 'loops can be nested' do
      processor = BrainFuck::Processor.new('[:->++[:-]<]:', [3, 0])
      output = StringIO.new
      i = BrainFuck::Interpreter.new(processor, $stdin, output)

      i.run

      expect(output.string).to eq '3 2 1 2 2 1 1 2 1 0 '
    end
  end

  describe '#run' do
    let(:hello_world_program) do
      <<~CODE
        ++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.
        >---.
        +++++++.
        .
        +++.
        >>.
        <-.
        <.
        +++.
        ------.
        --------.
        >>+.
        >++.
      CODE
        .freeze
    end

    it '+++++: prints 5' do
      processor = BrainFuck::Processor.new('+++++:', [0])
      output = StringIO.new
      i = BrainFuck::Interpreter.new(processor, $stdin, output)
      i.run
      expect(output.string).to eq '5 '
    end

    it 'prints !' do
      processor = BrainFuck::Processor.new('++++++++ ++++++++ ++++++++ ++++++++ +.', [0])
      output = StringIO.new
      i = BrainFuck::Interpreter.new(processor, $stdin, output)
      i.run
      expect(output.string).to eq '!'
    end

    it 'hello world' do
      processor = BrainFuck::Processor.new(hello_world_program, Array.new(20, 0))
      output = StringIO.new
      i = BrainFuck::Interpreter.new(processor, $stdin, output)
      i.run
      expect(output.string).to eq "Hello World!\n"
    end

    it 'an empty program exits immediately' do
      processor = BrainFuck::Processor.new('', [0])
      i = BrainFuck::Interpreter.new(processor)
      expect { i.run }.not_to raise_error
    end
  end
end
