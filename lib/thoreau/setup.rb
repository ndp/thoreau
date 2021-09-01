module Thoreau

  class Setup

    attr_reader :name, :values, :block

    def initialize name, values, block
      @name = name
      @values = values
      # @value = [values].flatten unless values.nil?
      @block = block
    end

  end
end
