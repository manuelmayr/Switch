module Switch

  class Resultset
    include Enumerable

    def initialize(enum)
      @enum = enum
    end

    def each
      if block_given? then
        @enum.each do |x|
          yield x
        end
      else
        @enum
      end
    end
  end

end
