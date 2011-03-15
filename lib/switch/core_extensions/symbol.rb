module Switch

  module SymbolExtensions

    def classify
      Inflector::camelize(self).to_sym
    end

    def methify
      Inflector::underscore(
        self.to_s.split("::").last).to_sym
    end

    Symbol.send :include, self
  end

end
