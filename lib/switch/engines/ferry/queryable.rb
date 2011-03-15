module Switch

  class Queryable
    private

      def to_plan_bundle
        plan = self.normalize.infer_boxing.compile
        type_map = { List.type => ::Locomotive::RelationalAlgebra::List.type,
                     Atom.type => ::Locomotive::RelationalAlgebra::Atom.type }
        type = ast.infer_implementation_type

        plan_bundle = ::Locomotive::RelationalAlgebra::
                        QueryPlanBundle.new( plan, type_map[type] )
      end

      def to_query_information_node
        self.normalize.infer_boxing.compile
      end

    public

    class << self
      attr_accessor :engine
    end

    def to_ary
      [self]
    end

    module Output
      def to_sql(file=nil)
        file_ = case
                  when File === file then file
                  when IO   === file then file
                  when String === file then File.open(file, "w")
                end

        plan_bundle = to_plan_bundle.to_xml
        sql = Queryable.engine.sql(plan_bundle).query_plan.map do |qp|
                qp.query
              end.join("\n")

        if file_.nil? then
          sql
        else
          file_.puts sql
          file_.flush
        end
      end

      def to_dot(file=nil, opt=nil)
        file_ = case
                  when File === file then file
                  when IO   === file then file
                  when String === file then File.open(file, "w")
                end

        plan_bundle = to_plan_bundle.to_xml
        dot = Queryable.engine.dot(plan_bundle, opt)
        if file_.nil? then
          dot
        else
          file_.puts dot
          file_.flush
        end
      end

      def to_plan(file=nil)
        file_ = case
                  when File === file then file
                  when IO   === file then file
                  when String === file then File.open(file, "w")
                end
        plan_bundle = to_plan_bundle.to_xml
        plan = Queryable.engine.plan(plan_bundle)
        if file_.nil? then
          plan
        else
          file_.puts plan.to_xml
          file_.flush
        end
      end

      def to_ruby
        qin = to_query_information_node
        # due to the rownum semantics
        # we can assure that the first
        # iter value is 1
        iter = 1
        ResultsetFactory.new(qin).get_array(iter)
      end
    end
    include Output

    module Enumerable
      private
        def heapify x
          case
            when ::Hash === x then x.map { |k,v| [k,heapify(v)] }.to_hash
            when ::Enumerable === x then x.map { |x| heapify x }
            else x
          end
        end

      public
        def each
          if block_given?
            to_ruby.each do |x|
              yield x
            end
          else
            to_ruby.each
          end
        end

        def all
          result = to_ruby.each.map { |x| heapify x }
          case self.normalize.infer_implementation_type
            # when returning an atom we can be sure that
            # the resulting list has exactly one element
            # being the overall result
            when Atom
              result.first
            # otherwise we simply return the list
            when List 
              result
          end
        end
    end
    include Enumerable
  end

end
