require 'brain_fuck'
require_relative '../../lib/brain_fuck/processor'

RSpec.describe BrainFuck::Processor do # rubocop:disable Metrics/BlockLength
  describe '#initialize' do
    it 'sets code' do
      processor = BrainFuck::Processor.new('abc', [1, 2, 3])
      expect(processor.code).to eq 'abc'
    end

    it 'sets code_ptr to 0' do
      processor = BrainFuck::Processor.new('abc', [1, 2, 3])
      expect(processor.code_ptr).to eq 0
    end

    it 'sets initial data' do
      processor = BrainFuck::Processor.new('abc', [1, 2, 3])
      expect(processor.data).to eq [1, 2, 3]
    end

    it 'sets data_ptr to 0' do
      processor = BrainFuck::Processor.new('abc', [1, 2, 3])
      expect(processor.data_ptr).to eq 0
    end
  end

  it '#advance_data_ptr increases the data pointer' do
    processor = BrainFuck::Processor.new('abc', [1, 2, 3])
    processor.advance_data_ptr
    expect(processor.data_ptr).to eq 1
  end

  it '#step_back_data_ptr decreases the data pointer' do
    processor = BrainFuck::Processor.new('abc', [1, 2, 3])
    processor.advance_data_ptr
    processor.step_back_data_ptr
    expect(processor.data_ptr).to eq 0
  end

  it '#increment_data increases the value at the current data location' do
    processor = BrainFuck::Processor.new('abc', [1, 2, 3])
    processor.increment_data
    expect(processor.data).to eq [2, 2, 3]
  end

  it '#decrement_data decreases the value at the current data location' do
    processor = BrainFuck::Processor.new('abc', [1, 2, 3])
    processor.decrement_data
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

  describe 'the stack' do
    it 'does push and pop things' do
      processor = BrainFuck::Processor.new('abc', [0])
      processor.push 1
      processor.push 2
      stack = [processor.pop, processor.pop]
      expect(stack).to eq [2, 1]
    end
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

  describe '#finished' do
    it 'returns false if code_ptr points to an instruction' do
      processor = BrainFuck::Processor.new('a', [0])
      expect(processor.finished?).to eq false
    end

    it 'returns true if code_ptr is beyond last instruction' do
      processor = BrainFuck::Processor.new('a', [0])
      processor.cmd
      expect(processor.finished?).to eq true
    end
  end

  describe '#rewind' do
    it 'moves code_ptr back 1' do
      processor = BrainFuck::Processor.new('abc', [0])
      processor.cmd
      processor.rewind
      expect(processor.code_ptr).to eq 0
    end

    it 'returns instruction at new code_ptr' do
      processor = BrainFuck::Processor.new('abc', [0])
      processor.cmd
      expect(processor.rewind).to eq 'a'
    end

    it 'raises error if you try to move before first instruction' do
      processor = BrainFuck::Processor.new('a', [0])
      expect { processor.rewind }.to raise_error BrainFuck::Error
    end
  end
end
