require 'forwardable'
require 'brain_fuck'

require_relative './processor'
require_relative './debug'
require_relative './instruction_handler'

module BrainFuck
  class Interpreter
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
    }.freeze

    def initialize(processor, input = $stdin, output = $stdout)
      @processor = processor
      @instruction_handler = BrainFuck::InstructionHandler.new(@processor, input, output)
    end

    def run
      (1..MAX_STEPS).each do
        step
        break if @processor.finished?
      end
    end

    private

    def step
      @instruction = @processor.cmd
      code = Interpreter::INSTRUCTION_SET[@instruction]
      @instruction_handler.send(code) if code
    end
  end
end
