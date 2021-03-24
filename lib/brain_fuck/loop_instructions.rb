module BrainFuck
  class LoopInstructions
    def initialize(processor)
      @processor = processor
    end

    def begin_loop
      return if @processor.get.positive?

      nested_block_count = 0
      loop do
        cmd = @processor.cmd
        nested_block_count += 1 if cmd == '['
        break if cmd == ']' && nested_block_count.zero?

        nested_block_count -= 1 if cmd == ']'
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
      end
    end
  end
end
