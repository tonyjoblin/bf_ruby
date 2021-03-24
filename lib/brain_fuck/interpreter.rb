require 'forwardable'
require 'brain_fuck'

require_relative './processor'
require_relative './debug'
require_relative './loop_instructions'

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

    def not_implemented
      raise Error.new('Instruction "#{@instruction}" not implemented')
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
      LoopInstructions.new(@processor).begin_loop
    end

    def end_loop
      LoopInstructions.new(@processor).end_loop
    end
  end
end
