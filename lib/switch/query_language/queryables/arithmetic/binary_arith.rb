module Switch

  module BinaryArith
    attributes :left,
               :right

    def initialize(left, right)
      @left =  StandardWrapper::wrap(left)
      @right = StandardWrapper::wrap(right)
    end
  end

end
