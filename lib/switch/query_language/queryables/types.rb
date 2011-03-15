module Switch

  class TType
    include Singleton

    class << self
      alias :type :instance
    end
  end

  class TDbl < TType; end
  class TDec < TDbl; end
  class TInt < TDec; end

  class TStr < TType; end

end
