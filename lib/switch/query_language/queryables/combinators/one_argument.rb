module Switch

  module OneArgument
    attributes :queryable,
               :queryable_arg

    def initialize(queryable, queryable_arg)
      @queryable = StandardWrapper::wrap queryable
      @queryable_arg = StandardWrapper::wrap queryable_arg
    end
  end

end
