require 'scanf'

require_relative './processor'

module BrainFuck
  class Interpreter
    MAX_STEPS = 2000

    attr_reader :processor

    def initialize(processor, input = STDIN, output = STDOUT)
      @processor = processor
      @input = input
      @output = output
    end

    def step
      instruction = @processor.cmd
      case instruction
      when '+'
        @processor.inc
      when '-'
        @processor.dec
      when '>'
        @processor.next
      when '<'
        @processor.prev
      when '.'
        @output.putc @processor.get.chr
      when ','
        @processor.set @input.getc.ord
      when ':'
        @output.write "#{@processor.get} "
      when ';'
        raise Brainfuck::Error.new('; not implemented')
      when '['
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
      when ']'
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

    def run
      (1..MAX_STEPS).each do
        step
        break if @processor.finished?
      end
    end

    def debug
      puts "mem: #{@processor.data} code_ptr: #{@processor.code_ptr}"
    end
  end
end
