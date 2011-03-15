module Switch

  module OneArgumentBlockArgument
    include LambdaHandling
    attributes :queryable,
               :queryable_arg,
               :lambda

    def initialize(queryable, queryable_arg, lam_alt = nil, &lam)
      @queryable = StandardWrapper::wrap queryable
      @queryable_arg = StandardWrapper::wrap queryable_arg

      @lambda = lam_alt.nil? ? handle_lambda(lam) :
                               lam_alt
    end
  end

end
