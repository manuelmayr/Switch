module SQLMatcher
  class IsSQL
    def initialize(expected)
      @expected = expected
    end

    def matches?(actual)
      @actual = actual
      @expected.gsub(/^--.*/,'').
                gsub(/\s+/, ' ').strip == @actual.gsub(/^--.*/,'').
                                                  gsub(/\s+/, ' ').strip
    end

    def failure_message
      "expected\n#{@actual}\nto be like\n#{@expected}"
    end

    def negative_failure_message
      "expected\n#{@actual}\nto be unlike\n#{@expected}"
    end
  end

  def is_SQL(expected)
    IsSQL.new(expected)
  end
end

