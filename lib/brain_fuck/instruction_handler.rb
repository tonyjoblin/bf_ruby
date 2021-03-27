module BrainFuck
  class InstructionHandler
    extend Forwardable

    def_delegators :@processor, :increment_data, :decrement_data, :step_back_data_ptr, :advance_data_ptr

    def initialize(processor, input, output)
      @processor = processor
      @input = input
      @output = output
    end

    def not_implemented
      raise Error, %(Instruction "#{@instruction}" not implemented)
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
      advance_to_end_of_loop if @processor.get.zero?
    end

    def end_loop
      nested_block_count = 0
      @processor.rewind
      loop do
        cmd = @processor.rewind
        nested_block_count += 1 if cmd == ']'
        break if cmd == '[' && nested_block_count.zero?

        nested_block_count -= 1 if cmd == '['
      end
    end

    private

    def advance_to_end_of_loop
      nested_block_count = 0
      loop do
        cmd = @processor.cmd
        nested_block_count += 1 if cmd == '['
        break if cmd == ']' && nested_block_count.zero?

        nested_block_count -= 1 if cmd == ']'
      end
    end
  end
end
