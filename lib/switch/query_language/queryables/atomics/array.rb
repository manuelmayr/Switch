module Switch

  class Ary < Atomic
    attributes :elements
    delegate :reduce,
             :to => :elements

    def initialize(element, *elements)
      @elements = [StandardWrapper::wrap(element)] +
                  elements.map do |elem|
                    StandardWrapper::wrap(elem)
                  end
    end
  end

end
