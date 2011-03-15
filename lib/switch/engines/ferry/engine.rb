module Switch
  class Engine
    private
      attr_reader :pathfinder

    public
    def initialize(ar = nil)
      @ar = ar
      @pathfinder = Switch::Pathfinder
    end

    def connection
      @ar.connection
    end

    def adapter_name
      @adapter_name ||= connection.adapter_name
    end

    def method_missing(method, *args, &block)
      @ar.connection.send(method, *args, &block)
    end

    module CRUD
      def create(relation)
        connection.insert(relation.to_sql)
      end

      def read(ast)
        # get the ferry translated bundle
        plan_bundle = relation.t
        # get the XML transformation
        # to process by pathfinder
        xml = plan_bundle.to_xml
        rows = connection.select_rows(pathfinder.sql(xml))
        Array.new(rows, relation.attributes)
      end

      def update(relation)
        connection.update(relation.to_sql)
      end

      def delete(relation)
        connection.delete(relation.to_sql)
      end
    end

    module FerrySpec
      def dot(plan_bundle, opt=nil)
        # get the XML transformation
        # to process by pathfinder
        xml = plan_bundle
        pathfinder.dot(xml,opt)
      end

      def sql(plan_bundle)
        # get the XML transformation
        # to process by pathfinder
        xml = plan_bundle
        pathfinder.sql(xml)
      end

      def plan(plan_bundle)
        # get the XML transformation
        # to process by pathfinder
        xml = plan_bundle
        pathfinder.plan(xml)
      end
    end
    include FerrySpec
  end
end
