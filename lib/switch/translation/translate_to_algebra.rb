module Switch

  class Environment
    include Locomotive::RelationalAlgebra
    extend Locomotive::RelationalAlgebra
    attributes :env

    delegate :[],
             :first,
             :map,
             :to => :env

    def map(&block)
      Environment.new(env.map(&block).to_hash)
    end

    def merge(hash)
      Environment.new(env.merge(hash))
    end
    alias :add :merge

    def lift(map)
      inner, outer = Iter(2), Iter(3)
      self.map do |v_i, itbl|
        cols_vi, itbls_vi = itbl.column_structure, itbl.surrogates
        [v_i, QueryInformationNode.new(
                itbl.plan.equi_join(map, Iter(1), outer).
                     project( { inner => [Iter(1)],
                                Pos(1) => [Pos(1)] }.
                                merge(
                                  cols_vi.items.map do |v|
                                    [v,[v]]
                                 end.to_hash) ),
                     cols_vi,
                     itbls_vi)]
      end
    end

    def initialize(hash = nil)
      @env = hash.nil? ? {} : hash
    end
  end

  module TranslateToAlgebra
    extend self
    extend Dispatcher
    include Locomotive::RelationalAlgebra
    extend  Locomotive::RelationalAlgebra

    private

      def RType(method_type, *params)
        if params.empty?
          ::Locomotive::RelationalAlgebra.const_get(
            "r_#{method_type.class.methify[2..-1]}".to_s.classify).type
        else
          send(method_type.classify.to_sym, *params)
        end
      end

      def RAttribute(name)
        ::Locomotive::RelationalAlgebra::Attribute.new(name.to_s)
      end

      def RVariable
        ::Locomotive::RelationalAlgebra::Variable
      end

      def assign_variables_to_cs(entries, variables)
        # there is at most one recordrest variables
        # in a lambda parameter
        rest_size = entries.size - variables.size
        assign = variables.reduce([]) do |ary, v|
                   s = ary.map { |r| r.to_a }.flatten.size
                   if RecordFieldVariable === v then
                     ary << (s..s)
                   elsif RecordRestVariable === v or
                         RecordSingleVariable === v then
                     ary << (s..s+rest_size)
                   end
                 end
        variables.zip(assign).map do |var,idx|
          if RecordRestVariable === var or
             RecordSingleVariable === var then
            entry = entries[idx] ? entries[idx] : []
            [var,ColumnStructure.new(entry)]
          else
            entry = entries[idx] ? entries[idx] : []
            entry = entry.map do |e|
                      case
                        when AttributeColumnStructure === e then
                          e.column_structure.entries
                        when OffsetType === e then
                          e
                      end
                    end.flatten

            [var,ColumnStructure.new(entry)]
          end
        end.to_hash
      end

      def variable_environment(vars, plan, surr)
        vars.map do |var,cs|
          cs_new = cs.adapt
          itbl_new = surr.filter_and_adapt cs.items
          plan_new = plan.project( { Iter(1) => [Iter(1)],
                                     Pos(1)  => [Pos(1)] }.
                                   merge(
                                     cs.items.zip(cs_new.items).map do |o,n|
                                       [o,[n]]
                                     end.to_hash))
          [var, QueryInformationNode.new(plan_new, cs_new, itbl_new)]
        end.to_hash
      end

      def create_mapping(q)
        inner, outer = Iter(2), Iter(3)
        q.row_num(inner, [], [Iter(1), Pos(1)]).
          project(Iter(1) => [outer],
                  inner => [inner],
                  Pos(1) => [Pos(2)] )
      end

      def compile_lambda(env, map, lam, context)
        inner = Iter(2)

        q_v = context.
              plan.row_num(inner, [], [Iter(1), Pos(1)]).
                   project( { inner => [Iter(1)] }.
                            merge(
                              context.column_structure.
                              items.map do |it|
                                [it, [it]]
                              end.to_hash)).
                   attach(AttachItem.new(Pos(1), RNat(1)))

        # lifting the environment
        env_ =  env.lift(map)

        # creating a new loop
        loop_v = q_v.project([Iter(1)])

        # support for pattern matching
        vars = assign_variables_to_cs(context.
                                      column_structure.entries,
                                      lam.variables)
        env_var = variable_environment(vars,
                                       q_v, context.surrogates)

        env_ = env_.add env_var
        [q_v, compile_(loop_v,  env_, lam.body)]
      end

    public

      [:int, :dbl, :str, :bool].each do |atomic|
        define_method(atomic) do |loop, env, ast|
          plan = loop.attach(AttachItem.new(Item(1), RType("r_#{atomic}", ast.value))).
                      attach(AttachItem.new(Pos(1), RNat(1)))

          QueryInformationNode.new(plan, [[Item(1),
                                           ::Locomotive::RelationalAlgebra.
                                             const_get("r_#{atomic}".to_s.classify).type]])
        end
      end

      def one_element_array(loop, env, ast)
        compile_(loop, env, ast.value)
      end

      def empty_array(loop, env, ast)
        plan = LiteralTable( Iter(1) => [], Pos(1) => [] )

        QueryInformationNode.new(plan, [])
      end

      [:plus, :minus,
       :multiplication, :division,
       :equal, :greater, :less ].each do |binop|
        define_method(binop) do |loop, env, ast|
          e1 = compile_(loop, env, ast.left)
          e2 = compile_(loop, env, ast.right)

          q_e1, q_e2 = e1.plan, e2.plan
          c = e1.column_structure[0].offset
          c_, res = c.inc, c.inc(2)
          c__ = c.inc(3)

          type1 = q_e1.schema[c].first
          type2 = q_e2.schema[c].first

          raise TypeNotFoundError,
                "Type for #{c.inspect} could not be found!" unless type1 and type2

          # calculating the less restrictive type,
          # if they are not equal and perform a cast
          if type1 != type2 then
             type = [type1.class, type2.class].max
             q_e1 = q_e1.cast(c_, c, type.type).
                         project( Iter(1) => [Iter(1)],
                                  Pos(1)  => [Pos(1)],
                                  c_      => [c] )
             q_e2 = q_e2.cast(c_, c, type.type).
                         project( Iter(1) => [Iter(1)],
                                  Pos(1)  => [Pos(1)],
                                  c_      => [c] )
          end

          plan = q_e1.project( Iter(1) => [Iter(2)],
                               c       => [c_] ).
                      equi_join(q_e2, Iter(2), Iter(1)).
                      send({:plus => :addition, :minus => :subtraction,
                            :multiplication => :multiplication,
                            :division => :division,
                            :equal    => :equal,
                            :greater => :greater_than,
                            :less    => :less_than}[binop],
                            res, [c_, c]).
                      project( Iter(1) => [Iter(1)],
                               Pos(1)  => [Pos(1)],
                               res     => [c] )

          QueryInformationNode.new(plan, e1.column_structure, {},
                                   e1.side_effects + e2.side_effects)
        end
      end

      def un_equal(loop, env, ast)
        e1 = compile_(loop, env, ast.left)
        e2 = compile_(loop, env, ast.right)

        q_e1, q_e2 = e1.plan, e2.plan
        c = e1.column_structure[0].offset
        c_, res, res_ = c.inc, c.inc(2), c.inc(3)
        c__ = c.inc(3)

        type1 = q_e1.schema[c].first
        type2 = q_e2.schema[c].first
        if type1 != type2 then
           type = [type1.class,type2.class].max
           q_e1 = q_e1.cast(c_, c, type.type).
                       project( Iter(1) => [Iter(1)],
                                Pos(1)  => [Pos(1)],
                                c_      => [c] )
           q_e2 = q_e2.cast(c_, c, type.type).
                       project( Iter(1) => [Iter(1)],
                                Pos(1)  => [Pos(1)],
                                c_      => [c] )
        end

        plan = q_e1.project( Iter(1) => [Iter(2)],
                             c       => [c_] ).
                    equi_join(q_e2, Iter(2), Iter(1)).
                    equal(res,  [c_, c]).
                    not(res_, res).
                    project( Iter(1) => [Iter(1)],
                             Pos(1)  => [Pos(1)],
                             res_    => [c] )

        QueryInformationNode.new(plan, e1.column_structure, {},
                                 e1.side_effects + e2.side_effects)

      end

      def ary(loop, env, ast)
        comp_elements = ast.elements.map do |el|
                          compile_(loop, env, el)
                        end
        ords = (1..comp_elements.size-1).to_a
        q_e, cols_e, itbls_e = comp_elements.last.plan,
                               comp_elements.last.column_structure,
                               comp_elements.last.surrogates
        ord, pos_, item_ = Iter(2), Pos(2), Iter(3)

        q = q_e.attach(AttachItem.new(ord, RNat(comp_elements.size)))

        # creating right deep plan
        q_ = comp_elements[0..-2].zip(ords).reverse.reduce(q) do |e1,e2|
               e2.first.plan.attach(AttachItem.new(ord, RNat(e2.last))).union(e1)
             end.row_num(item_, [], [Iter(1), ord, Pos(1)])

        q__ = q_.row_rank(pos_, [ord, Pos(1)]).
               project( { Iter(1) => [Iter(1)],
                          pos_    => [Pos(1)] }.
                          merge(
                            (cols_e - itbls_e.keys).items.
                              map { |it| [it,[it]] }.
                              to_hash).
                          merge(
                            { item_ => itbls_e.keys }) )

        itbls_ = comp_elements.first.surrogates.
                               itapp(q_, *comp_elements[1..-1].map { |i| i.surrogates })

        side = comp_elements.reduce(SideEffects.new([])) do |side1,side2|
                  side1 + side2.side_effects
               end

        QueryInformationNode.new(q__, cols_e, itbls_, side)
      end

      def record(loop, env, ast)
        # collecting all names corresponding query plans
        attr = ast.attributes.map do |a,q|
                 [a, compile_(loop, env, q)]
               end.to_hash

        iter_, pos_ = Iter(2), Pos(2)

        a_e1 = attr.first
        q_e1, cols_e1, itbls_e1 = a_e1.last.plan,
                                  a_e1.last.column_structure,
                                  a_e1.last.surrogates

        e1 = QueryInformationNode.new(
               q_e1, [[RAttribute(attr.first.first.name),
                       cols_e1]], itbls_e1)

        attr.to_a.rest.reduce(e1) do |e_1, a_e_2|
          cs2 = a_e_2.last.column_structure.clone
          max_id = e_1.column_structure.items.max.id
          cs2.items.each { |it| it.inc!(max_id) }
          cs_new = e_1.column_structure.add(
                        [[RAttribute(a_e_2.first.name),
                          cs2]])
          itbls2 = a_e_2.last.surrogates.clone
          itbls2.keys.each { |it| it.inc!(max_id) }

          QueryInformationNode.new(
            e_1.plan.equi_join(
                a_e_2.last.plan.project({ Iter(1) => [iter_],
                                          Pos(1)  => [pos_] }.
                                 merge(
                                   a_e_2.last.column_structure.items.map do |it|
                                     [it, [it.inc(max_id)]]
                                   end.to_hash)),
                Iter(1), iter_).
                project([Iter(1), Pos(1)] + cs_new.items),
            cs_new,
            e_1.surrogates + itbls2,
            e_1.side_effects + a_e_2.last.side_effects)
        end
      end

      [:greater_than_or_equal, :less_than_or_equal].each do |binop|
        define_method(binop) do |loop, env, ast|
          e1 = compile_(loop, env, ast.left)
          e2 = compile_(loop, env, ast.right)

          q_e1, q_e2 = e1.plan, e2.plan
          c = e1.column_structure[0].offset
          c_, res, res_, res__ = *(1..4).map { |i| c.inc(i) }

          # equality
          eq = q_e1.project( Iter(1) => [Iter(2)],
                               c       => [c_] ).
                      equi_join(q_e2, Iter(2), Iter(1)).
                      equal(res, [c, c_]).
                      project([Iter(1), Pos(1), res])

          # greater or less comparison
          comp = q_e1.project( Iter(1) => [Iter(2)],
                               c       => [c_] ).
                      equi_join(q_e2, Iter(2), Iter(1)).
                      send({:greater_than_or_equal => :greater_than,
                            :less_than_or_equal    => :less_than}[binop],
                            res, [c_, c]).
                      project( Iter(1) => [Iter(2)],
                               Pos(1)  => [Pos(2)],
                               res     => [res_] )
          # equal or greater(less)
          plan = eq.
                 equi_join(comp, Iter(1), Iter(2)).
                 or(res__, [res, res_]).
                 project( Iter(1) => [Iter(1)],
                          Pos(1)  => [Pos(1)],
                          res__ => [c] )

          QueryInformationNode.new(plan, e1.column_structure, {},
                                   e1.side_effects + e2.side_effects)
        end
      end


      [:and, :or].each do |bool|
        define_method(bool) do |loop, env, ast|
          e1 = compile_(loop, env, ast.left)
          e2 = compile_(loop, env, ast.right)

          q_e1, q_e2 = e1.plan, e2.plan
          c = e1.column_structure[0].offset
          c_, res = c.inc, c.inc(2)

          q = q_e1.project( Iter(1) => [Iter(2)],
                               c       => [c_] ).
                      equi_join(q_e2, Iter(2), Iter(1)).
                      send(bool, res, [c, c_]).
                      project({ Iter(1) => [Iter(1)],
                                Pos(1)  => [Pos(1)],
                                res => [c] })

          QueryInformationNode.new(q,  e1.column_structure, {},
                                   e1.side_effects + e2.side_effects)
        end
      end

      def append(loop, env, ast)
        e1 = compile_(loop, env, ast.queryable)
        e2 = compile_(loop, env, ast.queryable_arg)

        q_e1, q_e2 = e1.plan, e2.plan
        cols, itbls_e1, itbls_e2 = e1.column_structure, e1.surrogates, e2.surrogates
        ord, item_, pos_ = Iter(2), cols.items.max.inc, Pos(2)

        q = q_e2.attach(AttachItem.new(ord, RNat(2))).
                 union(q_e1.attach(AttachItem.new(ord, RNat(1)))).
                 row_num(item_, [], [Iter(1), ord, Pos(1)])

        q_ = q.row_rank(pos_, [ord, Pos(1)]).
               project( { Iter(1) => [Iter(1)],
                          pos_    => [Pos(1)] }.
                          merge(
                            (cols - itbls_e1.keys).items.
                              map { |it| [it,[it]] }.
                              to_hash).
                          merge(
                            { item_ => itbls_e1.keys }) )

        itbls_ = itbls_e1.itapp(q, itbls_e2)

        QueryInformationNode.new(q_, cols, itbls_,
                                 e1.side_effects + e2.side_effects)
      end

      def at(loop, env, ast)
        e1 = compile_(loop, env, ast.queryable_arg)
        e2 = compile_(loop, env, ast.queryable)

        q_e1, c = e1.plan, e1.column_structure[0].offset
        c_ = e2.column_structure.items.max.inc
        c__ = c_.inc
        q_e2, cols, itbls = e2.plan, e2.column_structure,
                            e2.surrogates
        iter_, pos_, pos__ = Iter(2), Pos(2), Pos(3)

        q = q_e1.project( Iter(1) => [iter_], c => [c_] ).
                 equi_join(q_e2.row_num(pos_, [Iter(1)], [Iter(1), Pos(1)]),
                           iter_, Iter(1)).
                 cast(c__, c_, RNat.type).
                 equal(pos__, [pos_, c__]).
                 select(pos__).
                 project( [Iter(1)] + cols.items ).
                 attach(AttachItem.new(Pos(1), RNat(1)))

        itbls_ = itbls.itsel(q)

        QueryInformationNode.new(q, cols, itbls_,
                                 e1.side_effects + e2.side_effects)
      end

      def flatten(loop, env, ast)
        e = compile_(loop, env, ast.queryable)

        q_e , c, itbls_e = e.plan, e.column_structure[0].offset, e.surrogates
        q_i, cols_i, itbls_i = itbls_e[c].plan, itbls_e[c].column_structure,
                               itbls_e[c].surrogates
        c_, iter_, pos_, pos__ = cols_i.items.max.inc,
                                   Iter(2), Pos(2), Pos(3)

        q = q_i.equi_join(q_e.project( Iter(1) => [iter_], Pos(1) => [pos_], c => [c_] ),
                          Iter(1), c_).
                row_rank(pos__, [pos_, Pos(1)]).
                project( { iter_ => [Iter(1)],
                           pos__ => [Pos(1)] }.merge(
                             cols_i.items.map do |i|
                               [i,[i]]
                             end.to_hash) )

        QueryInformationNode.new(q, cols_i, itbls_i, e.side_effects)
      end

      def drop(loop, env, ast)
        e1 = compile_(loop, env, ast.queryable_arg)
        e2 = compile_(loop, env, ast.queryable)

        q_e1, c = e1.plan, e1.column_structure[0].offset
        c_ = e2.column_structure.items.max.inc
        c__ = c_.inc
        q_e2, cols, itbls = e2.plan, e2.column_structure, e2.surrogates
        iter_, pos_, pos__ = Iter(2), Pos(2), Pos(3)

        q = q_e1.project( Iter(1) => [iter_], c => [c_] ).
                 equi_join(q_e2.row_num(pos_, [Iter(1)], [Iter(1), Pos(1)]),
                           iter_, Iter(1)).
                 cast(c__, c_, RNat.type).
                 greater_than(pos__, [pos_, c__]).
                 select(pos__).
                 project( { Iter(1) => [Iter(1)],
                            pos_    => [Pos(1)] }.
                          merge(
                            cols.items.map { |i| [i,[i]] } ))

        itbls_ = itbls.itsel(q)

        QueryInformationNode.new(q, cols, itbls_,
                                 e1.side_effects + e2.side_effects)
      end

      def take(loop, env, ast)
        e1 = compile_(loop, env, ast.queryable_arg)
        e2 = compile_(loop, env, ast.queryable)

        q_e1, c = e1.plan, e1.column_structure[0].offset
        c_ = e2.column_structure.items.max.inc
        c__ = c_.inc
        q_e2, cols, itbls = e2.plan, e2.column_structure, e2.surrogates
        iter_, pos_, pos__,
        pos___, pos____ = Iter(2), Pos(2), Pos(3), Pos(4), Pos(5)

        q = q_e1.project( Iter(1) => [iter_], c => [c_] ).
                 equi_join(q_e2.row_num(pos_, [Iter(1)], [Iter(1), Pos(1)]),
                           iter_, Iter(1)).
                 cast(c__, c_, RNat.type).
                 less_than(pos__, [pos_, c__]).
                 equal(pos___, [pos_, c__]).
                 or(pos____, [pos__,pos___]).
                 select(pos____).
                 project( { Iter(1) => [Iter(1)],
                            pos_    => [Pos(1)] }.
                          merge(
                            cols.items.map { |i| [i,[i]] } ))

        itbls_ = itbls.itsel(q)

        QueryInformationNode.new(q, cols, itbls_,
                                 e1.side_effects + e2.side_effects)
      end

      def box(loop, env, ast)
        ti_e = compile_(loop, env, ast.queryable)
        c = Item(1)

        q_0 = loop.project( Iter(1) => [Iter(1), c] ).
              attach(AttachItem.new(Pos(1), RNat(1)))

        QueryInformationNode.new(q_0, [[c,RNat.type]], { c => ti_e })
      end

      def unbox(loop, env, ast)
        e = compile_(loop, env, ast.queryable)

        q_e, c, itbls_e = e.plan, e.column_structure[0].offset, e.surrogates

        q_i, cols_i, itbls_i = itbls_e[c].plan, itbls_e[c].column_structure, itbls_e[c].surrogates
        item_, iter_ = cols_i.items.max.inc, Iter(2)

        q_ = q_i.equi_join(q_e.project( Iter(1) => [iter_], c => [item_] ),
                           Iter(1), item_).
                 project( { iter_  => [Iter(1)],
                            Pos(1) => [Pos(1)] }.
                          merge(
                            cols_i.items.map { |i| [i,[i]] }.
                            to_hash))


        QueryInformationNode.new(q_, cols_i, itbls_i, e.side_effects)
      end

      def table(loop, env, ast)
        i = 0
        cols = ColumnStructure.new(ast.attributes.map do |a,ty|
                                         [RAttribute(a.name),
                                          [[Item(i+=1), RType(ty)]]]
                                       end)
        keys = ast.keys.map { |k| cols[RAttribute(k.name)].items }.flatten
        order = ast.order.map { |o| cols[RAttribute(o.name)].items }.flatten

        q = RefTbl.new(ast.name, cols.map do |entry|
                                   [entry.attribute, entry.column_structure[0].type]
                                 end.to_hash,
                                 keys).
                   row_rank(Pos(1), order).cross(loop)

        QueryInformationNode.new(q, cols)
      end

      def attribute_accessor(loop, env, ast)
        e = compile_(loop, env, ast.queryable)
        attr = RAttribute(ast.attr.name)

        q_e, cols_e, itbls_e = e.plan, e.column_structure, e.surrogates

        raise AttributeNotFoundError,
              "Attribute #{attr.inspect} not found!" unless cols_e[attr]

        # adapt the column structure
        cols_new = cols_e[attr].adapt
        itbls_new = itbls_e.filter_and_adapt(cols_e[attr].items)

        q = q_e.project( { Iter(1) => [Iter(1)],
                           Pos(1)  => [Pos(1)] }.
                         merge(
                           cols_e[attr].items.
                           zip(cols_new.items).map do |it, it_new|
                             [it, [it_new]]
                           end.to_hash) )

        QueryInformationNode.new(q, cols_new, itbls_new,
                                 e.side_effects)
      end

      def map(loop, env, ast)
        e1 = compile_(loop, env, ast.queryable)

        q_e1, cols_e1, itbls_e1 = e1.plan, e1.column_structure,
                                  e1.surrogates

        inner, outer, pos_ = Iter(2), Iter(3), Pos(2)

        # create a mapping
        map = create_mapping(q_e1)

        lam = compile_lambda(env, map, ast.lambda, e1).last

        q_lam, cols_lam, itbls_lam = lam.plan, lam.column_structure,
                                     lam.surrogates

        # mapping join to combine the loop-lifted expression
        # with the outer query
        q_ = q_lam.equi_join(map, Iter(1), inner).
               project( { outer => [Iter(1)],
                          Pos(2) => [Pos(1)] }.
                        merge(
                          cols_lam.items.map do |it|
                            [it,[it]]
                          end.to_hash) )

        QueryInformationNode.new(q_, cols_lam, itbls_lam,
                                 e1.side_effects + lam.side_effects)
      end

      def select(loop, env, ast)
        e1 = compile_(loop, env, ast.queryable)

        q_e1, cols_e1, itbls_e1 = e1.plan, e1.column_structure,
                                  e1.surrogates

        inner, outer, old_pos = Iter(2), Iter(3), Pos(2)

        # create a mapping
        map = create_mapping(q_e1)

        q_v, lam = compile_lambda(env, map, ast.lambda, e1)

        q_lam, cols_lam, itbls_lam = lam.plan, lam.column_structure,
                                     lam.surrogates

        item_new = cols_e1.items.max.inc

        q_ = q_lam.equi_join(map, Iter(1), inner).
                   project( inner   => [inner],
                            outer   => [outer],
                            old_pos => [old_pos],
                            Item(1) => [item_new] ).
                   select(item_new).
                   equi_join(q_v, inner, Iter(1)).
                   project( { outer   => [Iter(1)],
                              old_pos => [Pos(1)] }.
                            merge(
                              cols_e1.items.map do |it|
                                [it, [it]]
                              end.to_hash) )

        itbls_ = itbls_e1.itsel(q_)

        QueryInformationNode.new(q_, cols_e1, itbls_,
                                 e1.side_effects + lam.side_effects)
      end

      [:take_while, :drop_while].each do |meth|
        define_method(meth) do |loop, env, ast|
          e1 = compile_(loop, env, ast.queryable)

          q_e1, cols_e1, itbls_e1 = e1.plan, e1.column_structure,
                                    e1.surrogates

          inner, outer, outer_, pos_ = Iter(2), Iter(3), Iter(4), Pos(3)

          # create a mapping
          map = create_mapping(q_e1)

          q_v, lam = compile_lambda(env, map, ast.lambda, e1)

          q_lam, cols_lam, itbls_lam = lam.plan, lam.column_structure,
                                       lam.surrogates

          mapping = q_lam.equi_join(map, Iter(1), inner)

          passing = mapping.not(Item(2), Item(1)).
                            select(Item(2)).
                            min(Pos(2), [Pos(2)], [outer]).
                            project({ outer  => [Iter(1)],
                                      Pos(2) => [Pos(1)] })

          no_pass = mapping.project([outer]).distinct.
                            difference(passing.project( Iter(1) => [outer])).
                            project({ outer => [outer_] })

          # get the minimum position where the passing criterion
          # is false grouped by the 
          pass = passing.
                          # in the case all elements passing we need to add
                          # an artificial false on the end of a list
                          union(mapping.equi_join(no_pass, outer, outer_).
                                        max(Pos(2), [Pos(2)], [outer]).
                                        attach(AttachItem.new(Pos(3), RNat(1))).
                                        addition(Pos(4), [Pos(2), Pos(3)]).                                   
                                        project({ outer  => [Iter(1)],
                                                  Pos(4) => [Pos(1)] }))

          q_ = pass.equi_join(map, Iter(1), outer).
                       send({ :take_while => :greater_than,
                              :drop_while => :less_than }[meth],
                            pos_, [Pos(1), Pos(2)])

          q__ = meth == :drop_while ? q_.equal(Pos(4), [Pos(1), Pos(2)]).
                                         or(Pos(5), [Pos(4), pos_]) :
                                      q_

          q___ = q__.select(meth == :drop_while ? Pos(5) : pos_). 
                     project([outer, Pos(2)]).
                     theta_join(q_e1, [Equivalence.new(outer, Iter(1)),
                                       Equivalence.new(Pos(2), Pos(1))]).
                     project([Iter(1), Pos(1)] + cols_e1.items)

          itbls_ = itbls_e1.itsel(q___)

          QueryInformationNode.new(q___, cols_e1, itbls_,
                                   e1.side_effects + lam.side_effects)
        end
      end

      [:max_by, :min_by].each do |meth|
        define_method(meth) do |loop, env, ast|
          e1 = compile_(loop, env, ast.queryable)
  
          q_e1, cols_e1, itbls_e1 = e1.plan, e1.column_structure,
                                    e1.surrogates
  
          inner, outer, outer_, pos_ = Iter(2), Iter(3), Iter(4), Pos(3)
  
          # create a mapping
          map = create_mapping(q_e1)
  
          q_v, lam = compile_lambda(env, map, ast.lambda, e1)
  
          q_lam, cols_lam, itbls_lam = lam.plan, lam.column_structure,
                                       lam.surrogates
  
          mapping = q_lam.equi_join(map, Iter(1), inner)
  
          # calculate the maximum the values
          # calculated in the lambda body
          max = mapping.
                  send({ :max_by => :max,
                         :min_by => :min }[meth], Item(1), [Item(1)], [outer])
  
          # now we need to get all the outer values
          # associated with this maximum value
          max_outer = max.project({ Item(1) => [Item(2)] }).
                          equi_join(mapping, Item(2), Item(1)).
                          project([outer, Pos(2)])
  
          q = q_e1.theta_join(max_outer, [Equivalence.new(Iter(1), outer),
                                          Equivalence.new(Pos(1), Pos(2))])
  
          # get only the first item
          q_ = q.row_num(Pos(3), [Iter(1)], [Pos(1)]).
                 attach(AttachItem.new(Pos(4), RNat(1))).
                 equal(Pos(5), [Pos(3), Pos(4)]).
                 select(Pos(5)).
                 project({ Iter(1) => [Iter(1)],
                           Pos(4)  => [Pos(1)] }.merge(
                             cols_e1.items.map do |it|
                               [it,[it]]
                             end.to_hash))
  
          itbls_ = itbls_e1.itsel(q_)
  
          QueryInformationNode.new(q_, cols_e1, itbls_,
                                   e1.side_effects + lam.side_effects)
        end
      end

      def partition(loop, env, ast)
        e1 = compile_(loop, env, ast.queryable)

        q_e1, cols_e1, itbls_e1 = e1.plan, e1.column_structure,
                                  e1.surrogates

        inner, outer, old_pos = Iter(2), Iter(3), Pos(2)

        # create a mapping
        map = create_mapping(q_e1)

        q_v, lam = compile_lambda(env, map, ast.lambda, e1)

        q_lam, cols_lam, itbls_lam = lam.plan,
                                     lam.column_structure, lam.surrogates

        item_new = cols_e1.items.max.inc

        q_ = q_lam.equi_join(map, Iter(1), inner).
                   project( inner   => [inner],
                            outer   => [outer],
                            old_pos => [old_pos],
                            Item(1) => [item_new] ).
                   equi_join(q_v, Iter(2), Iter(1)).
                   project( { outer   => [Iter(1)],
                              old_pos => [Pos(1)] }.
                            merge(
                              ([[item_new, [item_new]]] +
                              cols_e1.items.map do |it|
                                [it, [it]]
                              end).to_hash) )

        q_true = q_.select(item_new).
                    project([Pos(1)] + cols_e1.items).
                    attach(AttachItem.new(Iter(1), RNat(1)))

        item_new_ = item_new.inc
        q_false = q_.not(item_new_, item_new).
                     select(item_new_).
                     project([Pos(1)] + cols_e1.items).
                     attach(AttachItem.new(Iter(1), RNat(2)))

        q_res = q_true.union(q_false)

        q_outer_ = q_e1.project([Iter(1)]).distinct

        q_outer = q_outer_.attach(AttachItem.new(Pos(1), RNat(1))).
                           attach(AttachItem.new(Item(1), RNat(1))).
                           union(q_outer_.attach(AttachItem.new(Pos(1), RNat(2))).
                                          attach(AttachItem.new(Item(1), RNat(2))))

        QueryInformationNode.new(q_outer,
                                 [[Item(1), RNat.type]],
                                 { Item(1) =>  QueryInformationNode.new(q_res, cols_e1, itbls_e1) },
                                 e1.side_effects)
      end

      def reverse(loop, env, ast)
        e = compile_(loop, env, ast.queryable)

        q_e, cols_e, itbls_e = e.plan, e.column_structure, e.surrogates

        q_res = q_e.row_rank(Pos(2), { Pos(1) => Descending.dir }).
                    project({ Iter(1) => [Iter(1)],
                              Pos(2)  => [Pos(1)] }.
                            merge(
                              cols_e.items.map do |it|
                                [it, [it]]
                              end.to_hash))

        QueryInformationNode.new(q_res, cols_e, itbls_e, e.side_effects)
      end

      def count(loop, env, ast)
        e = compile_(loop, env, ast.queryable)

        q_e, cols_e, itbls_e = e.plan, e.column_structure, e.surrogates

        item = Item(1)
        q = q_e.count(item, [], [Iter(1)])
        q_ = loop.difference(q.project([Iter(1)])).
                  attach(AttachItem.new(item, RInt(0))).
                  union(q).attach(AttachItem.new(Pos(1), RNat(1)))

        QueryInformationNode.new(q_, [[Item(1),RInt.type]], {},
                                 e.side_effects)
      end

      [:max, :min, :avg, :sum].each do |aggr|
        define_method(aggr) do |loop, env, ast|
          e = compile_(loop, env, ast.queryable)

          q_e, cols_e, itbls_e = e.plan, e.column_structure, e.surrogates

          item = cols_e.items[0]
          q = q_e.send(aggr, item, [item], [Iter(1)]).
                  attach(AttachItem.new(Pos(1), RNat(1)))
          side = loop.difference(q.project([Iter(1)])).
                              attach(AttachItem.new(
                                       Item(1),
                                       RStr("#{aggr} for empty lists is undefined"))).
                              project([Item(1)])

          QueryInformationNode.new(q, cols_e, {},
                                   e.side_effects + [side])
        end
      end

      def all(loop,env,ast)
          e = compile_(loop, env,
                        Map.new(
                          ast.queryable,
                          ast.lambda))

          q_e, cols_e, itbls_e = e.plan, e.column_structure, e.surrogates
          item = cols_e.items[0]

          q = q_e.all(item, [item], [Iter(1)])
          q_ = loop.difference(q.project([Iter(1)])).
                    attach(AttachItem.new(item, RBool(true))).
                    union(q).attach(AttachItem.new(Pos(1), RNat(1)))

          QueryInformationNode.new(q_, [[Item(1),RBool.type]], {},
                                   e.side_effects)
      end

      def any(loop,env,ast)
          e = compile_(loop, env,
                        Select.new(
                          ast.queryable,
                          ast.lambda))

          q_e, cols_e, itbls_e = e.plan, e.column_structure, e.surrogates
          item = cols_e.items[0]
          item_, item__ = item.inc, item.inc(2)

          q = q_e.project([Iter(1)]).
                  distinct.
                  attach(AttachItem.new(item, RBool(true)))
          
#          not(item_, item).
#                  all(item_, [item_], [Iter(1)]).
#                  not(item__, item_).
#                  project( Iter(1) => [Iter(1)],
#                           item__  => [item] )

          q_ = loop.difference(q.project([Iter(1)])).
                    attach(AttachItem.new(item, RBool(false))).
                    union(q).attach(AttachItem.new(Pos(1), RNat(1)))

          QueryInformationNode.new(q_, [[Item(1),RBool.type]], {},
                                   e.side_effects)
      end



      def sort_by(loop, env, ast)
        e = compile_(loop, env, ast.queryable)
        ord = compile_(loop, env,
                       Map.new(
                         ast.queryable,
                         ast.lambda))

        q_e, cols_e, itbls_e = e.plan, e.column_structure, e.surrogates
        q_ord, cols_ord = ord.plan, ord.column_structure
        item, item_, iter_, pos_, pos__ = cols_ord.items[0], cols_e.items.max.inc,
                                   Iter(2), Pos(2), Pos(3)

        q = q_ord.project({ Iter(1) => [iter_],
                            Pos(1)  => [pos_],
                            item    => [item_] }).
                  theta_join(q_e,
                     [Equivalence.new(iter_, Iter(1)),
                      Equivalence.new(pos_, Pos(1))]).
                  rank(pos__, [item_]).
                  project({ Iter(1) => [Iter(1)],
                            pos__   => [Pos(1)] }.
                          merge(
                            cols_e.items.map do |it|
                              [it,[it]]
                            end))

        QueryInformationNode.new(q, cols_e, itbls_e,
                                    e.side_effects + ord.side_effects)
      end

      def group_with(loop, env, ast)
        e = compile_(loop, env,
                           Map.new(
                             ast.queryable,
                             Lambda.new(
                               *ast.lambda.variables,
                               Record.new( :key => ast.lambda.variables[0],
                                           :grp => ast.lambda.body ))))

        q_e_eg, cols_e_eg, itbls_e_eg = e.plan, e.column_structure, e.surrogates
        cols_e, cols_eg = cols_e_eg[RAttribute(:key)],
                          cols_e_eg[RAttribute(:grp)]
        grpkey, pos_ = Iter(2), Pos(2)

        q = q_e_eg.row_rank(grpkey, cols_eg.items)
        cols_eg_new = cols_eg.adapt
        item_ = cols_eg_new.items.max.inc

        q_o = q.project({ Iter(1) => [Iter(1)],
                          grpkey  => [item_] }.
                        merge(
                          cols_eg.items.zip(
                            cols_eg_new.items).map do |it, it_new|
                            [it,[it_new]]
                          end.to_hash)).
                distinct.row_num(Pos(1), [Iter(1)], [item_])

        q_i = q.row_num(pos_, [grpkey], [Pos(1)]).
                project({ grpkey => [Iter(1)],
                          pos_   => [Pos(1)] }.
                        merge(
                          cols_e.items.map do |it|
                            [it,[it]]
                          end))

        QueryInformationNode.new(q_o, [[RAttribute(:key), cols_eg_new],
                                       [RAttribute(:grp), [[item_, RNat.type]]]],
                                 { item_ => QueryInformationNode.new(q_i, cols_e, itbls_e_eg) },
                                 e.side_effects)
      end

      def uniq(loop, env, ast)
        e = compile_(loop, env, ast.queryable)

        q_e, cols_e = e.plan, e.column_structure, e.surrogates

        q = q_e.project([Iter(1)] + cols_e.items).
                distinct.attach(AttachItem.new(Pos(1), RNat(42)))

        QueryInformationNode.new(q, cols_e, {}, e.side_effects)
      end

      def zip(loop, env, ast)
        e = compile_(loop, env, ast.queryable)
        qin = e.surrogates.join

        QueryInformationNode.new(
          qin.plan, e.column_structure, 
          qin.surrogates)
      end

      def unzip(loop, env, ast)
        e = compile_(loop, env, ast.queryable)
        
        q_e, cols_e, itbls_e = e.plan,
                               e.column_structure, e.surrogates

        items = (1..cols_e.count).map { |it| Item(it) }
        q = loop.project({ Iter(1) => [Iter(1)] + items }).
                 attach(AttachItem.new(Pos(1), RNat(1)))

        itbls = e.frag

        QueryInformationNode.new(q, cols_e, itbls)
      end

      def lambda(loop, env, ast)
        variables = ast.variables
        var = variables[0]
        env_ = env.add( var => QueryInformationNode.new(
                               RVariable().new_variable(*env[var].column_structure.items),
                               env[var].column_structure, env[var].surrogates) )

        body = compile_(loop, env_, ast.body)

        q_body = RelLambda.new(
                   env_[var].plan,
                   body.plan)

        QueryInformationNode.new(q_body, body.column_structure, body.surrogates)
      end

      def variable(loop, env, ast)
        # this is just a lookup in the environment
        env[ast]
      end

      def unwrap(loop, env, ast)
        compile_(loop, env, ast.queryable)
      end

      def compile_(loop, env, ast)
        dispatch(ast.class, loop, env, ast)
      end

      def compile(ast)
        plan =  compile_(
                  LiteralTable.new( Iter(1) => [RNat(1)] ),
                  Switch::Environment.new,
                  ast)
      end
  end

end
