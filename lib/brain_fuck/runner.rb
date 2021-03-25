module BrainFuck
  class Runner
    def initialize(code)
      processor = BrainFuck::Processor.new(code, Array.new(100, 0))
      @interpreter = BrainFuck::Interpreter.new(processor)
    end

    def run
      @interpreter.run
    end
  end
end
