module Switch

  module BoxingInference
    extend self
    extend Dispatcher
    extend Conformance

    [:binary_arith, :binary_comparable].each do |bin|
      define_method(bin) do |env, ast|
        ast.class.new(
          infer_(env, ast.left), infer_(env, ast.right))
      end
    end

    def ary(env, ast)
      Ary.new(
        conformance(
          ast.elements.first.infer_implementation_type,
          Atom.type,
          infer_(env, ast.elements.first)),
        *ast.elements.rest.map do |element|
          conformance(
            element.infer_implementation_type,
            Atom.type,
            infer_(env, element))
        end)
    end

    def record(env, ast)
      boxed_record = ast.map do |attr, val|
                           [attr,
                             conformance(
                               val.infer_implementation_type,
                               Atom.type,
                               infer_(env, val))]
                         end.to_hash
      Record.new(boxed_record)
    end

    def attribute_accessor(env, ast)
      AttributeAccessor.new(
        infer_(env, ast.queryable), ast.attr)
    end

    def block_argument(env, ast)
      signature = env[ast.class.methify]
      ast.class.new(
        conformance(
          ast.queryable.infer_implementation_type,
          signature.parameters.first,
          infer_(env, ast.queryable)),
          Lambda.new(
            *ast.lambda.variables,
            conformance(
              ast.lambda.body.infer_implementation_type,
              Atom.type,
              infer_(env, ast.lambda.body))))
    end

    def one_argument_block_argument(env, ast)
      signature = env[ast.class.methify]
      ast.class.new(
        conformance(
          ast.queryable.infer_implementation_type,
          signature.parameters[0],
          infer_(env, ast.queryable)),
       conformance(
          ast.queryable_arg.infer_implementation_type,
          signature.parameters[1],
          infer_(env, ast.queryable_arg)),
       Lambda.new(
         *ast.lambda.variables,
         infer_(env, ast.lambda.body)))
    end

    def no_argument(env, ast)
      signature = env[ast.class.methify]
      ast.class.new(
        conformance(
          ast.queryable.infer_implementation_type,
          signature.parameters.first,
          infer_(env, ast.queryable)))
    end

    def one_argument(env, ast)
      signature = env[ast.class.methify]
      ast.class.new(
        conformance(
          ast.queryable.infer_implementation_type,
          signature.parameters.first,
          infer_(env, ast.queryable)),
        conformance(
          ast.queryable_arg.infer_implementation_type,
          signature.parameters.last,
          infer_(env, ast.queryable_arg)))
    end

    def one_element_array(env, ast)
      OneElementArray.new(
        conformance(
          ast.value.infer_implementation_type,
          Atom.type,
          infer_(env, ast.value)))
    end

    [:variable, :atomic, :table, :empty_array].each do |op|
      define_method(op) { |env, ast| ast }
    end

    def infer_(env, ast)
      dispatch(ast.class, env, ast)
    end

    def infer(ast)
      infer_(ImplementationTypeInference::COMBINATOR_SIG, ast)
    end
  end

end
