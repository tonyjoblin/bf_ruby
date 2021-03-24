module BrainFuck
  class Processor
    attr_reader :code, :code_ptr
    attr_reader :data, :data_ptr

    def initialize(code, data)
      @code = code
      @code_ptr = 0
      @data = data
      @data_ptr = 0
      @stack = []
    end

    def cmd
      validate_code_ptr
      instruction = @code[@code_ptr]
      @code_ptr += 1
      instruction
    end

    def rewind
      @code_ptr -= 1
      validate_code_ptr
      @code[@code_ptr]
    end

    def finished?
      @code_ptr >= @code.length
    end

    def advance_data_ptr
      @data_ptr += 1
      validate_data_ptr
    end

    def step_back_data_ptr
      @data_ptr -= 1
      validate_data_ptr
    end

    def increment_data
      @data[@data_ptr] += 1
    end

    def decrement_data
      @data[@data_ptr] -= 1
    end

    def set(x)
      @data[@data_ptr] = x
    end

    def get
      @data[@data_ptr]
    end

    def push(x)
      @stack.push(x)
    end

    def pop
      @stack.pop
    end

    private

    def validate_code_ptr
      raise BrainFuck::Error.new("Bad code_ptr #{@code_ptr}") if @code_ptr.negative? || finished?
    end

    def validate_data_ptr
      raise BrainFuck::Error.new("Bad data_ptr #{@code_ptr}") if @data_ptr.negative? || @data_ptr >= @data.length
    end
  end
end
