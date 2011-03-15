module Switch

  module StandardWrapper
    extend self

    def wrap(value)
      case
        when Queryable === value then value
        when Fixnum === value then Int.new(value)
        when Float  === value then Dbl.new(value)
        when String === value then Str.new(value)
        when TrueClass === value then Bool.new(value)
        when FalseClass === value then Bool.new(value)
        when Symbol === value then Attribute.new(value)
        when Array  === value then
          value.empty? ?
            EmptyArray.new :
            Ary.new(
              *value.map do |elem|
                wrap(elem)
              end)
        when Hash === value then
          # this is a new record
          Record.new(
            value.map do |k, v|
              [Attribute.new(k), wrap(v)]
            end.to_hash)
        else raise ArgumentError, "value from block is not known"
      end
    end

  end

end
