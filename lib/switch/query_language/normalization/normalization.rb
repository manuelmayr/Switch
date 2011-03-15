module Switch

  module Normalization
    extend self
    extend Dispatcher

    [:binary_arith, :binary_comparable].each do |bin_op|
      define_method(bin_op) do |ast|
        ast.class.new(
          ast.left.normalize, ast.right.normalize)
      end
    end

    def record(ast)
      normalized_record = ast.map do |attr, val|
                                [attr, val.normalize]
                              end.to_hash
      Record.new(normalized_record)
    end

    def attribute_accessor(ast)
      AttributeAccessor.new(
        ast.queryable.normalize,
        ast.attr)
    end

    def block_argument(ast)
      ast.class.new(
        ast.queryable.normalize,
        Lambda.new(
          *ast.lambda.variables,
          ast.lambda.body.normalize))
    end

    def one_argument_block_argument(ast)
      ast.class.new(
        ast.queryable.normalize,
        ast.queryable_arg.normalize,
        Lambda.new(
          *ast.lambda.variables,
          ast.lambda.body.normalize))
    end

    def no_argument(ast)
      ast.class.new(
        ast.queryable.normalize)
    end

    def one_argument(ast)
      ast.class.new(
        ast.queryable.normalize,
        ast.queryable_arg.normalize)
    end

    def max_over(ast)
      Max.new(
        Map.new(
          ast.queryable.normalize,
          ast.lambda))
    end

    def min_over(ast)
      Min.new(
        Map.new(
          ast.queryable.normalize,
          ast.lambda))
    end

    def sum_over(ast)
      Sum.new(
        Map.new(
          ast.queryable.normalize,
          ast.lambda))
    end

    def avg_over(ast)
      Avg.new(
        Map.new(
          ast.queryable.normalize,
          ast.lambda))
    end

    def flat_map(ast)
      Flatten.new(
        Map.new(
          ast.queryable.normalize,
          ast.lambda))
    end

    def reject(ast)
      Select.new(
        ast.queryable.normalize,
        Lambda.new(
          *ast.lambda.variables,
          Equal.new(
            ast.lambda.body.normalize,
            Bool.new(false))))
    end

    def first(ast)
      At.new(
        ast.queryable.normalize,
        Int.new(1))
    end

    def ary(ast)
      array = ast.elements
      if array.one? and
         RecordRestVariable === array[0] then
         array[0]
      else
        Ary.new(*array.map { |e| e.normalize })
      end
    end

    [:one, :none].each do |meth|
      define_method(meth) do |ast|
      Equal.new(
        Count.new(
          Select.new(
            ast.queryable.normalize,
            Lambda.new(
              *ast.lambda.variables,
              ast.lambda.body.normalize))),
        meth == :one ? Int.new(1) :
                       Int.new(0))
      end
    end

    def member(ast)
      x = RecordSingleVariable.new
      Any.new(
        ast.queryable,
        Lambda.new(
          x,
          Equal.new(
            x,
            ast.queryable_arg)))
    end

    def lambda(ast)
      Lambda.new(
        *ast.variables,
        ast.body.normalize)
    end

    [:variable, :atomic, :table,
     :empty_ary, :one_elementary].each do |leaf|
      define_method(leaf) { |ast| ast }
    end

    def normalize_(ast)
      dispatch(ast.class, ast)
    end

    def normalize(ast)
      normalize_(ast)
    end

  end

end
