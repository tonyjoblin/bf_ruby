module BrainFuck
  class Debug
    def self.out(processor)
      puts "mem: #{processor.data} code_ptr: #{processor.code_ptr}"
    end
  end
end
