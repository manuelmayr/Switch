module Switch

  module VariableArguments
    attributes :queryables

    def initialize(first, *rest)
      @queryables = [StandardWrapper::wrap(first)] +
                    rest.map do |arg|
                      StandardWrapper::wrap arg
                    end
    end
  end

end
