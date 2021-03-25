require 'brain_fuck'
require_relative '../../lib/brain_fuck/interpreter'

RSpec.describe BrainFuck::Interpreter do
  it 'can construct and inject a processor' do
    processor = BrainFuck::Processor.new('abc', [0, 0, 0])
    i = BrainFuck::Interpreter.new(processor)
    expect(i.processor).to eq processor
  end

  it '#step ; (input integer) raises error' do
    processor = BrainFuck::Processor.new(';', [0, 0, 0])
    i = BrainFuck::Interpreter.new(processor)
    expect { i.step }.to raise_error BrainFuck::Error
  end

  it '#step advances the code_ptr' do
    processor = BrainFuck::Processor.new('a', [0])
    i = BrainFuck::Interpreter.new(processor)
    i.step
    expect(processor.finished?).to eq true
  end

  it '#step can execute + (increment_data) command' do
    processor = BrainFuck::Processor.new('+', [0])
    i = BrainFuck::Interpreter.new(processor)
    i.step
    expect(processor.get).to eq 1
  end

  it '#step can execute the - (decrement_data) command' do
    processor = BrainFuck::Processor.new('-', [1])
    i = BrainFuck::Interpreter.new(processor)
    i.step
    expect(processor.get).to eq 0
  end

  it '#step can exectute the > (advance_data_ptr) command' do
    processor = BrainFuck::Processor.new('>', [0, 1])
    i = BrainFuck::Interpreter.new(processor)
    i.step
    expect(processor.get).to eq 1
  end

  it '#step can exectute the < (step_back_data_ptr) command' do
    processor = BrainFuck::Processor.new('><', [0, 1])
    i = BrainFuck::Interpreter.new(processor)
    i.step
    i.step
    expect(processor.get).to eq 0
  end

  it '#step can execute the . (output) command' do
    processor = BrainFuck::Processor.new('.', [65])
    input = StringIO.new
    output = StringIO.new
    i = BrainFuck::Interpreter.new(processor, input, output)
    i.step
    expect(output.string).to eq 'A'
  end

  it '#step can execute the , (input) command' do
    processor = BrainFuck::Processor.new(',', [0])
    input = StringIO.new('A')
    output = StringIO.new
    i = BrainFuck::Interpreter.new(processor, input, output)
    i.step
    expect(processor.get).to eq 65
  end

  it '#step can execute the : command' do
    processor = BrainFuck::Processor.new(':', [123])
    input = StringIO.new
    output = StringIO.new
    i = BrainFuck::Interpreter.new(processor, input, output)
    i.step
    expect(output.string).to eq '123 '
  end

  describe '#step igores unknown instructions' do
    it 'moves code pointer to next instruction' do
      processor = BrainFuck::Processor.new('Q', [0])
      i = BrainFuck::Interpreter.new(processor)
      i.step
      expect(processor.finished?).to eq true
    end

    it 'does not change the data' do
      processor = BrainFuck::Processor.new('Q', [0])
      i = BrainFuck::Interpreter.new(processor)
      i.step
      expect(processor.get).to eq 0
    end
  end

  describe 'loops' do
    it 'loops until data is zero' do
      processor = BrainFuck::Processor.new('[:-]:', [3])
      input = StringIO.new
      output = StringIO.new
      i = BrainFuck::Interpreter.new(processor, input, output)

      i.run

      expect(output.string).to eq '3 2 1 0 '
    end

    it 'loops can be nested' do
      processor = BrainFuck::Processor.new('[:->++[:-]<]:', [3, 0])
      input = StringIO.new
      output = StringIO.new
      i = BrainFuck::Interpreter.new(processor, input, output)

      i.run

      expect(output.string).to eq '3 2 1 2 2 1 1 2 1 0 '
    end
  end

  describe '#run' do
    it '+++++: prints 5' do
      processor = BrainFuck::Processor.new('+++++:', [0])
      input = StringIO.new
      output = StringIO.new
      i = BrainFuck::Interpreter.new(processor, input, output)
      i.run
      expect(output.string).to eq '5 '
    end

    it 'prints !' do
      processor = BrainFuck::Processor.new('++++++++ ++++++++ ++++++++ ++++++++ +.', [0])
      input = StringIO.new
      output = StringIO.new
      i = BrainFuck::Interpreter.new(processor, input, output)
      i.run
      expect(output.string).to eq '!'
    end

    it 'hello world' do
      code = <<~CODE
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

      processor = BrainFuck::Processor.new(code, Array.new(20, 0))
      input = StringIO.new
      output = StringIO.new
      i = BrainFuck::Interpreter.new(processor, input, output)
      i.run
      expect(output.string).to eq "Hello World!\n"
    end
  end
end
