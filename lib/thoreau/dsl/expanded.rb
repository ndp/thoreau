require 'active_support'
require 'active_support/core_ext/module/delegation'

module Thoreau
  module DSL
    class Expanded
      def initialize a
        @a = a
      end

      delegate :map, :each, to: :@a
    end
  end
end
