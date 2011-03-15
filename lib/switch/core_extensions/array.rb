module Switch

  module ArrayExtension
    def flatten_once
      self.flatten(1)
    end

    def rest
      self[1..-1]
    end

    def to_hash
      Hash[*self.flatten_once]
    end

    Array.send :include, self
  end

end

class Array
  alias :at_ :[]

  def [](index)
    if self.one? and
       Switch::RecordRestVariable === self.at_(0) and
       (Symbol === index or
        Switch::Attribute === index) then
       Switch::AttributeAccessor.new(self.at_(0), index)
    else
      self.at_(index)
    end
  end
end


