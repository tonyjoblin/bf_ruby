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
      @processor.rewind
      rewind_to_start_of_loop
    end

    private

    def rewind_to_start_of_loop
      loop do
        cmd = @processor.rewind
        rewind_to_start_of_loop if cmd == ']'
        break if cmd == '['
      end
    end

    def advance_to_end_of_loop
      loop do
        cmd = @processor.cmd
        advance_to_end_of_loop if cmd == '['
        break if cmd == ']'
      end
    end
  end
end
