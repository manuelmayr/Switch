module Switch

  module LambdaHandling
    private
    def handle_parameter(mode)
      case mode
        when :req, :opt then RecordFieldVariable.new
        when :rest      then RecordRestVariable.new
        else raise StandardError, "Variable mode #{mode} unknown"
      end
    end

    public
    def handle_lambda(lam)
      parameters = lam.parameters

      if parameters.one? then
        bound_vars = [parameters[0].first == :rest ?
                        RecordRestVariable.new :
                        RecordSingleVariable.new]
      else
        bound_vars = lam.parameters.map do |mode, name|
                       handle_parameter(mode)
                     end
      end

      lam_expr = Lambda.new(
                   *bound_vars,
                   StandardWrapper.wrap(lam[*bound_vars]))
    end
  end

end
