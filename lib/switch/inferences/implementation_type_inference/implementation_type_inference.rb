module Switch

  module ImplementationTypeInference
    extend self
    extend Dispatcher

    public

      COMBINATOR_SIG = {
        :map        => Func.new(
                         List.type, Func.new(Atom.type,Atom.type),
                         List.type),
        :flat_map    => Func.new(
                         List.type, Func.new(Atom.type,Atom.type),
                         List.type),
        :select     => Func.new(
                         List.type, Func.new(Atom.type,Atom.type),
                         List.type),
        :reject     => Func.new(
                         List.type, Func.new(Atom.type,Atom.type),
                         List.type),
        :partition   => Func.new(
                         List.type, Func.new(Atom.type,Atom.type),
                         List.type),
        :reverse     => Func.new(
                         List.type, List.type),
        :sort_by     => Func.new(
                         List.type, Func.new(Atom.type,Atom.type),
                         List.type),
        :distinct   => Func.new(List.type,List.type),
        :all        => Func.new(
                         List.type, Func.new(Atom.type,Atom.type),
                         Atom.type),
        :any        => Func.new(
                         List.type, Func.new(Atom.type,Atom.type),
                         Atom.type),
        :append     => Func.new(
                         List.type, List.type,
                         List.type),
        :flatten    => Func.new(
                         List.type,
                         List.type),
        :member     => Func.new(
                         Func.new(List.type,Atom.type),
                         Atom.type),
        :at         => Func.new(
                         List.type, Atom.type,
                         Atom.type),
        :first      => Func.new(
                         List.type, Atom.type),
        :take       => Func.new(
                         List.type, Atom.type,
                         List.type),
        :take_while  => Func.new(
                         List.type, Func.new(Atom.type,Atom.type),
                         List.type),
        :drop       => Func.new(
                         List.type, Atom.type,
                         List.type),
        :drop_while  => Func.new(
                         List.type, Func.new(Atom.type,Atom.type),
                         List.type),
        :max        => Func.new(List.type,Atom.type),
        :min        => Func.new(List.type,Atom.type),
        :max_by     => Func.new(
                         List.type, Func.new(Atom.type,Atom.type),
                         Atom.type),
        :min_by     => Func.new(
                         List.type, Func.new(Atom.type,Atom.type),
                         Atom.type),
        :count      => Func.new(List.type,Atom.type),
        :sum        => Func.new(List.type,Atom.type),
        :avg        => Func.new(List.type,Atom.type),
        :sum        => Func.new(List.type,Atom.type),
        :group_with => Func.new(
                         List.type, Func.new(Atom.type, Atom.type),
                         List.type),
        :zip        => Func.new(
                         Atom.type, List.type),
        :unzip      => Func.new(
                         List.type, Atom.type),
        :uniq       => Func.new(
                         List.type,
                         List.type),
        :unwrap     => Func.new(
                         List.type,
                         Atom.type)
      }

      [:table, :ary, :empty_array, :one_element_array].each do |struct|
        define_method(struct) { |env, ast| List.type }
      end

      [:record, :atomic, :variable,
       :binary_arith, :binary_comparable, :attribute_accessor].each do |tab|
        define_method(tab) { |env, ast| Atom.type }
      end

      def lambda(env, ast)
        Func.new(Atom.type, infer_(new_env, ast.body))
      end

      def combinator(env, ast)
        env[ast.class.methify].output
      end

      def infer_(env, ast)
        dispatch(ast.class, env, ast)
      end

      def infer(ast)
        infer_ COMBINATOR_SIG, ast
      end
  end

end

