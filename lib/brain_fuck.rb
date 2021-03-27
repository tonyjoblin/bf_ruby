# frozen_string_literal: true

require_relative 'brain_fuck/version'
require 'brain_fuck/interpreter'
require 'brain_fuck/processor'
require 'brain_fuck/runner'

module BrainFuck
  class Error < StandardError; end

  def self.run(code, memory_size = 100)
    Runner.new(code, memory_size).run
  end
end
