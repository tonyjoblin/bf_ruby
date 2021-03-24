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
    processor = BrainFuck::Processor.new('abc', [0, 0, 0])
    i = BrainFuck::Interpreter.new(processor)
    i.step
    expect(processor.code_ptr).to eq 1
  end

  it '#step can execute + command' do
    processor = BrainFuck::Processor.new('+', [0, 0, 0])
    i = BrainFuck::Interpreter.new(processor)
    i.step
    expect(processor.data).to eq [1, 0, 0]
  end

  it '#step can execute the - command' do
    processor = BrainFuck::Processor.new('-', [1])
    i = BrainFuck::Interpreter.new(processor)
    i.step
    expect(processor.data).to eq [0]
  end

  it '#step can exectute the > command' do
    processor = BrainFuck::Processor.new('>', [0, 0])
    i = BrainFuck::Interpreter.new(processor)
    i.step
    expect(processor.data_ptr).to eq 1
  end

  it '#step can exectute the < command' do
    processor = BrainFuck::Processor.new('><', [0, 0])
    i = BrainFuck::Interpreter.new(processor)
    i.step
    i.step
    expect(processor.data_ptr).to eq 0
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
    expect(processor.data).to eq [65]
  end

  it '#step can execute the : command' do
    processor = BrainFuck::Processor.new(':', [123])
    input = StringIO.new
    output = StringIO.new
    i = BrainFuck::Interpreter.new(processor, input, output)
    i.step
    expect(output.string).to eq '123 '
  end

  it '#step igores unknown instructions' do
    processor = BrainFuck::Processor.new('Q+', [0, 1])
    i = BrainFuck::Interpreter.new(processor)
    i.step
    expect(processor.code_ptr).to eq 1
    expect(processor.data_ptr).to eq 0
    expect(processor.data).to eq [0, 1]
  end

  describe 'begin loop [' do
    it 'moves to next instruction if data non zero' do
      processor = BrainFuck::Processor.new('[+]-', [1])
      i = BrainFuck::Interpreter.new(processor)
      i.step
      expect(processor.code_ptr).to eq 1
    end

    it 'moves to instruction after ] if data zero' do
      processor = BrainFuck::Processor.new('[+]-', [0])
      i = BrainFuck::Interpreter.new(processor)
      i.step
      expect(processor.code_ptr).to eq 3
    end

    it 'skips over nested loops' do
      processor = BrainFuck::Processor.new('[[[]]]-', [0])
      i = BrainFuck::Interpreter.new(processor)
      i.step
      expect(processor.code_ptr).to eq 6
    end
  end

  describe 'end loop ]' do
    it 'moves back to the begin loop instruction' do
      processor = BrainFuck::Processor.new('[]', [1])
      i = BrainFuck::Interpreter.new(processor)
      expect(processor.code_ptr).to eq 0
      i.step
      expect(processor.code_ptr).to eq 1
      i.step
      expect(processor.code_ptr).to eq 0
    end

    it 'moves back over nested loops' do
      processor = BrainFuck::Processor.new('[-[]]', [1])
      i = BrainFuck::Interpreter.new(processor)
      expect(processor.code_ptr).to eq 0
      i.step
      expect(processor.code_ptr).to eq 1
      i.step
      expect(processor.code_ptr).to eq 2
      i.step
      expect(processor.code_ptr).to eq 4
      i.step
      expect(processor.code_ptr).to eq 0
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
