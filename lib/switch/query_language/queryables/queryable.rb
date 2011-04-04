module Switch

  class Queryable

    module Combinators
      [:map, :flat_map, :select, :reject, :sum, :sort_by,
       :group_with, :max_over, :min_over,
       :sum_over, :avg_over, :partition,
       :take_while, :drop_while, :max_by, :min_by].each do |method|
        define_method(method) do |&lambda|
          Switch.const_get(method.classify).new(self, &lambda)
        end
      end

      [:collect, :collect_concat].each do |alias_|
        define_method(alias_) do |&lambda|
          aliases = { :collect => :map,
                      :collect_concat => :flat_map }
          Switch.const_get(aliases[alias_].classify).new(self, &lambda)
        end
      end


      [:all?, :any?,
       :none?, :one?].each do |existential|
        define_method(existential) do |&lambda|
          mapping = { :any? => :any, :all? => :all,
                      :none? => :none, :one? => :one }
          Switch.const_get(mapping[existential].classify).new(self, &lambda)
        end
      end


      [:cross].each do |method|
        define_method(method) do |*queryables|
          Switch.const_get(method.classify).new(self, *queryables)
        end
      end

      [:min, :max, :count, :avg,
       :sum, :uniq, :reverse, :first,
       :zip, :unzip, :unwrap].each do |method|
        define_method(method) do |*queryables|
          Switch.const_get(method.classify).new(self)
        end
      end

      [:length, :size].each do |method|
        define_method(method) do |*queryables|
          Switch.const_get(:Count).new(self)
        end
      end


      [:take, :drop].each do |method|
        define_method(method) do |value|
          Switch.const_get(method.classify).new(self, value)
        end
      end

      [:append, :at].each do |method|
        define_method(method) do |queryable|
          Switch.const_get(method.classify).new(self, queryable)
        end
      end

      [:member?].each do |method|
        define_method(method) do |value|
          mapping = { :member? => :member }
          Switch.const_get(mapping[method].classify).new(self, value)
        end
      end


      [:flatten].each do |method|
        define_method(method) do
          Switch.const_get(method.classify).new(self)
        end
      end
    end
    include Combinators

    module Arithmetic
      [:+, :-, :*, :/].each do |method|
        define_method(method) do |right_op|
          methods = { :+  => :Plus,
                      :-  => :Minus,
                      :*  => :Multiplication,
                      :/  => :Division }
          Switch.const_get(methods[method]).new(self, right_op)
        end
      end
      [:+@, :-@].each do |method|
        define_method(method) do
          methods = { :+@ => :UnaryPlus,
                      :-@ => :UnaryMinus }
          Switch.const_get(methods[method]).new(self)
        end
      end
    end
    include Arithmetic


    module Comparables
      [:==, :!=, :<, :<=, :>, :>=, :and, :or].each do |method|
        define_method(method) do |right_op|
          methods = { :== => :Equal,
                      :!= => :UnEqual,
                      :<  => :Less,
                      :<= => :LessThanOrEqual,
                      :>  => :Greater,
                      :>= => :GreaterThanOrEqual,
                      :or => :Or,
                      :and => :And }
          Switch.const_get(methods[method]).new(self, right_op)
        end
      end
      def !
        Switch.const_get(:Not).new(self)
      end
    end
    include Comparables

    module Tables
      [:[]].each do |method|
        define_method(method) do |attribute|
          methods = { :[] => :AttributeAccessor }
          Switch.const_get(methods[method]).new(self, attribute)
        end
      end

      def method_missing(attr, *args, &lam)
        AttributeAccessor.new(self, attr.to_sym)
      end
    end
    include Tables

    module Inferences
      def infer_implementation_type
        ImplementationTypeInference::infer self
      end

      def infer_boxing
        BoxingInference::infer self
      end
    end
    include Inferences

    module FlatteningTransformation
      def flattening
        Flattening::flattening self
      end
    end
    include FlatteningTransformation

    module Core
      def normalize
        Normalization::normalize self
      end
    end
    include Core

    module Compilation
      def compile
        TranslateToAlgebra::compile(self)
      end
    end
    include Compilation

    module Coercion
      def coerce(caller_)
        [StandardWrapper::wrap(caller_), self]
      end
    end
    include Coercion
  end

end
