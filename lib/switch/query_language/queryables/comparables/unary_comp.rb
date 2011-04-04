module Switch

  module UnaryComparable
    attributes :queryable

    def initialize(queryable)
      @queryable = StandardWrapper::wrap(queryable)
    end
  end

end
