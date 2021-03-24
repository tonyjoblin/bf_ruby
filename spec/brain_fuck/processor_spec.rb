require_relative '../../lib/brain_fuck/processor'

RSpec.describe BrainFuck::Processor do
  it '#initialize constructs Processor with given code and data' do
    processor = BrainFuck::Processor.new('abc', [1, 2, 3])
    expect(processor.code).to eq 'abc'
    expect(processor.code_ptr).to eq 0
    expect(processor.data).to eq [1, 2, 3]
    expect(processor.data_ptr).to eq 0
  end

  it '#next increases the data pointer' do
    processor = BrainFuck::Processor.new('abc', [1, 2, 3])
    processor.next
    expect(processor.data_ptr).to eq 1
  end

  it '#prev decreases the data pointer' do
    processor = BrainFuck::Processor.new('abc', [1, 2, 3])
    processor.next
    processor.prev
    expect(processor.data_ptr).to eq 0
  end

  it '#inc increases the value at the current data location' do
    processor = BrainFuck::Processor.new('abc', [1, 2, 3])
    processor.inc
    expect(processor.data).to eq [2, 2, 3]
  end

  it '#dec decreases the value at the current data location' do
    processor = BrainFuck::Processor.new('abc', [1, 2, 3])
    processor.dec
    expect(processor.data).to eq [0, 2, 3]
  end

  it '#set saves an int at the current data location' do
    processor = BrainFuck::Processor.new('abc', [1, 2, 3])
    processor.set 65
    expect(processor.data).to eq [65, 2, 3]
  end

  it '#get returns the int at the current data location' do
    processor = BrainFuck::Processor.new('abc', [65, 2, 3])
    expect(processor.get).to eq 65
  end

  it 'has a stack' do
    processor = BrainFuck::Processor.new('abc', [0])
    processor.push 1
    processor.push 2
    expect(processor.pop).to eq 2
    expect(processor.pop).to eq 1
  end

  it '#cmd returns current instruction' do
    processor = BrainFuck::Processor.new('abc', [0])
    expect(processor.cmd).to eq 'a'
  end

  it '#cmd increments the code_ptr' do
    processor = BrainFuck::Processor.new('abc', [0])
    processor.cmd
    expect(processor.code_ptr).to eq 1
  end

  it '#finished? returns true if code_ptr has reached end of code' do
    processor = BrainFuck::Processor.new('abc', [0])
    processor.cmd
    expect(processor.finished?).to eq false
    processor.cmd
    expect(processor.finished?).to eq false
    processor.cmd
    expect(processor.finished?).to eq true
  end

  it '#rewind moves code_ptr back 1 and returns instruction there' do
    processor = BrainFuck::Processor.new('abc', [0])
    processor.cmd
    expect(processor.rewind).to eq 'a'
    expect(processor.code_ptr).to eq 0
  end
end
