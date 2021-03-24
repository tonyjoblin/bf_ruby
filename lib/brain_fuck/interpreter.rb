require 'forwardable'

require_relative './processor'
require_relative './debug'

module BrainFuck
  class Interpreter
    extend Forwardable

    def_delegators :@processor, :increment_data, :decrement_data, :step_back_data_ptr, :advance_data_ptr

    MAX_STEPS = 2000

    attr_reader :processor

    INSTRUCTION_SET = {
      '+' => :increment_data,
      '-' => :decrement_data,
      '>' => :advance_data_ptr,
      '<' => :step_back_data_ptr,
      '.' => :output_data_as_char,
      ',' => :input_data_from_char,
      ':' => :output_data_as_integer,
      ';' => :not_implemented,
      '[' => :begin_loop,
      ']' => :end_loop
    }

    def initialize(processor, input = STDIN, output = STDOUT)
      @processor = processor
      @input = input
      @output = output
    end

    def step
      @instruction = @processor.cmd
      code = Interpreter::INSTRUCTION_SET[@instruction]
      if code
        send(code)
      end
    end

    def run
      (1..MAX_STEPS).each do
        step
        break if @processor.finished?
      end
    end

    private

    def not_implemented(instruction)
      raise Brainfuck::Error.new('Instruction "#{@instruction}" not implemented')
    end

    def output_data_as_char
      @output.putc @processor.get.chr
    end

    def input_data_from_char
      @processor.set @input.getc.ord
    end

    def output_data_as_integer
      @output.write "#{@processor.get} "
    end

    def begin_loop
      if @processor.get == 0
        nested_block_count = 0
        loop do
          cmd = @processor.cmd
          nested_block_count += 1 if cmd == '['
          break if cmd == ']' && nested_block_count.zero?
          nested_block_count -= 1 if cmd == ']'
          raise Brainfuck::Error.new("move to end of loop failed, nested_block_count: #{nested_block_count}") if nested_block_count.negative?
          raise Brainfuck::Error.new("move to end of loop failed, nested_block_count: #{nested_block_count}") if 10 < nested_block_count
        end
      end
    end

    def end_loop
      nested_block_count = 0
      @processor.rewind
      loop do
        cmd = @processor.rewind
        nested_block_count += 1 if cmd == ']'
        break if cmd == '[' && nested_block_count.zero?
        nested_block_count -= 1 if cmd == '['
        raise Brainfuck::Error.new("rewind to start of loop failed, nested_block_count: #{nested_block_count}") if nested_block_count.negative?
        raise Brainfuck::Error.new("rewind to start of loop failed, nested_block_count: #{nested_block_count}") if 10 < nested_block_count
      end
    end
  end
end
