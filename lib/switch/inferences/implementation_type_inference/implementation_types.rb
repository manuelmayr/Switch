module Switch

  class ImplementationType
  end

  # our Implementation types are either a atom,
  # or a list
  # In a database the corresponding types are the
  # row or the table
  class Atom < ImplementationType
    include Singleton

    class << self
      alias :type :instance
    end
  end

  class List < ImplementationType
    include Singleton

    class << self
      alias :type :instance
    end
  end

  class Func < ImplementationType
    attributes :parameters,
               :output

    def initialize(*parameters, output)
      @parameters = parameters
      @output = output
    end
  end

end
