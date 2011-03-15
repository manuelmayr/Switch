require "rexml/document"

module Switch
  module Pathfinder
    extend ::Pathfinder
    extend self

    public

      def sql(xml)
        xml = compile_to_sql(optimize(xml))
        Query_Plan_Bundle.from_xml(xml)
      end

      def plan(xml)
        sql(xml)
      end

      def dot(xml, opt=nil)
        compile_to_dot(optimize(xml))
      end
  end
end
