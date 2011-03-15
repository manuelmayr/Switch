module Switch

  module Conformance
    extend self

    def conformance(implementation_type1, implementation_type2, ast)
      return ast if implementation_type1 == implementation_type2
      return Box.new(ast) if implementation_type2 == Atom.type
      Unbox.new(ast)
    end
  end

end
