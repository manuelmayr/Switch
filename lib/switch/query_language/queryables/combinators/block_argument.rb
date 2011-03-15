module Switch

  module BlockArgument
    include LambdaHandling
    attributes :queryable,
               :lambda

    def initialize(queryable, lam_alt = nil, &lam)
      @queryable = StandardWrapper::wrap(queryable)

      @lambda = lam_alt.nil? ? handle_lambda(lam) :
                               lam_alt
    end

  end

end
