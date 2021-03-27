module BrainFuck
  class Runner
    def initialize(code, memory_size = 100)
      processor = BrainFuck::Processor.new(code, Array.new(memory_size, 0))
      @interpreter = BrainFuck::Interpreter.new(processor)
    end

    def run
      @interpreter.run
    rescue StandardError => e
      puts e
      puts @interpreter.processor.debug_dump_state
      throw e
    end
  end
end
