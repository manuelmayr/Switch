module Switch

  module OneValueArgument
    attributes :queryable,
               :value

    def initialize(queryable, value)
      @queryable = StandardWrapper::wrap queryable
      @value = value
    end
  end

end
