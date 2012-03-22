module Switch

  class ResultsetFactory
    private
      attr_reader :query_plan,
                  :surrogates

      def cast(type)
        case type
          when "nat"  then ->(x) { x.to_i }
          when "int"  then ->(x) { x.to_i }
          when "str"  then ->(x) { x }
          when "dec",
               "dbl"  then ->(x) { Float(x) }
          when "bool" then ->(x) { x.to_i == 1 }
        end
      end

      def lam_offset
        [->(x) { x.first }, 1]
      end

      def lam_attribute(entries)
        # calculate the lambda of the underlying structures
        lam_ary = entries.map do |entry|
                    [entry.attribute.name.to_sym,
                     lam_mat(entry.column_structure)]
                  end

        [->(x){
          arg_init = 0
          res = {}
          lam_ary.each do |attr, lam|
            arg_count = lam.last
            arg_range = arg_count == 1 ?
                          arg_init..arg_init :
                          arg_init..(arg_init+arg_count-1)
            arg_init = (arg_init+arg_count)
            res[attr] = lam.first[x[arg_range]]
          end
          res },
         lam_ary.reduce(0) { |a,b| a + b.last.last }]
      end

      def lam_mat(cs)
        # if we have an attribute on the first
        # place, we can be sure that the following
        # entries are attributes too
        if ::Locomotive::RelationalAlgebra::
             AttributeColumnStructure ===
             cs.entries[0]
          lam_attribute(cs)
        # otherwise we just have an offset
        else
          lam_offset
        end
      end

      def create_resultset(iter)
        Resultset.new(
          Enumerator.new do |yielder|
            # procrastinate the evaluation of the
            # SQL Query until the first call of
            # Enumerator#next.
            # Since active_record lacks support of
            # database cursor we load the whole result
            # into the heap.
            @result ||= Queryable.engine.
                            select_all(@qpb.query_plan.first.
                                           query).each

            # get the first item out of the result
            @next ||= begin
                        @result.next
                      rescue
                        { @iter_.to_s => -1 }
                      end

            # infer the schema from pathfinder names
            # this has to be done only once per nesting level
            @schema_map ||= @next.map do |k,v|
                           if /\A(?<item>[a-z]+\d+)_(?<type>[a-z]+)\z/i =~ k
                              [item, type]
                           else
                             raise StandardError, "Not an item name"
                           end
                         end.to_hash

            # infer the casting from the names we get from
            # pathfinder, this has to be done only once per
            # nesting level
            @cast_map ||= @schema_map.map do |i,t|
                            ["#{i}_#{t}", cast(t)]
                          end.to_hash

            @cs ||= query_plan.cols
            @lam_mat ||= lam_mat(@cs).first
            @offsets ||= @cs.items

            loop do
              # given that curr is not initialized yet
              # block until the thread returns the
              # result and initialize the query

              curr = @next
              # cast the result and convert the names into
              # symbols
              curr_ = {}
              curr.each do |k,v|
                curr_[k.to_sym] = @cast_map[k][v]
              end
              curr = curr_

              # materialize the result
              if curr[@iter_] == iter
                ary = @offsets.map do |offs|
                        offs_ = offs.id - 1
                        item_name = @items[offs_]
                        type = @schema_map["#{item_name}"]

                        if type != "nat"
                          curr["#{item_name}_#{type}".to_sym]
                        else
                          it = "#{item_name}_#{offs_}"
                          @array[it] ||= ResultsetFactory.new(
                                           surrogates[offs])
                          @array[it].get_array(
                             curr["#{item_name}_nat".to_sym])
                        end
                      end

                yielder.yield(@lam_mat.call(ary))
              end
              raise StopIteration if curr[@iter_] > iter

              # get the next item or stops the
              # iteration if no other element can be found
              @next = @result.next
            end
          end)
      end

    public
      include Enumerable

      def initialize(qin)
        @surrogates = qin.surrogates
        @array = {}
        # build a serialize operator
        ser = ::Locomotive::RelationalAlgebra::
                SerializeRelation.new(
                  qin.side_effects.plan, # side_effects
                  qin.plan, # the queryplan
                  ::Locomotive::RelationalAlgebra::
                      Iter.new(1),
                  ::Locomotive::RelationalAlgebra::
                      Pos.new(1),
                  qin.column_structure.items)
       # create a queryplan needed by the optimizer
       # and SQL generator
       @query_plan =
            ::Locomotive::RelationalAlgebra::
                QueryPlan.new(
                  ser,                  # serialize operator
                  qin.column_structure, # columnstructure
                  0)                    # QueryPlan id

        # feed the queryplan to the optimizer and
        # generate a SQL query
        @qpb = Queryable.engine.sql(query_plan.to_xml)
        # find the item columns
        @items = @qpb.query_plan.first.
                    schema.column.select { |c|
                       c.function == "item" }.
                    map { |c| [c.position, c.name.to_sym] }.to_hash
        # and the iter column, there only exactly one,
        # hence we return the first in the list
        @iter_  = "#{@qpb.query_plan.first.
                    schema.column.select { |c|
                       c.function == "iter" }.
                    map { |c| c.name.to_sym }.first
                   }_nat".to_sym

      end

      def get_array(iter)
        # create an enumerator to loop
        # over the result
        create_resultset(iter)
      end
  end

end
