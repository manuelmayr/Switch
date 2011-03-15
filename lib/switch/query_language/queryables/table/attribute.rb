module Switch

  class Attribute < Queryable
    attributes :name

    def initialize(name)
      @name = name.to_sym
    end

    module Hashable
      def eql?(other)
        self.==(other)
      end

      def hash
        self.name.hash
      end
    end
    include Hashable
  end
end
