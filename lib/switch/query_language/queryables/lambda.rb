module Switch

  class Lambda < Queryable
    attributes :variables,
               :body

    def initialize(*variables, body)
      @variables = variables
      @body = body
    end

  end

end
