module Switch

  module NoArgument
    attributes :queryable

    def initialize(queryable)
      @queryable = StandardWrapper::wrap queryable
    end
  end

end
