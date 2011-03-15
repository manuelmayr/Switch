module Switch

  module StringExtensions
    def classify
      Inflector::camelize(self)
    end

    String.send :include, self
  end

end
