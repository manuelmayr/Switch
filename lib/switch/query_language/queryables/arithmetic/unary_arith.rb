module Switch

  module UnaryArith
    attributes :queryable

    def initialize(queryable)
      @queryable = StandardWrapper::wrap(queryable)
    end
  end

end
