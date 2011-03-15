require "roxml"

module Switch

class Column
  include ROXML

  xml_reader :name, :required => true, :from => :attr
  xml_reader :function, :required => true, :from => :attr
  xml_reader :new?, :from => :attr
  xml_reader :position, :from => :attr, :as => Integer
end

class Schema
  include ROXML

  xml_reader :column, :required => true, :as => [Column]
end

class Property
  include ROXML

  xml_reader :name, :required => true, :from => :attr
  xml_reader :value, :required => true, :from => :attr
end

class QueryPlan
  include ROXML

  xml_reader :id, :required => true, :from => :attr, :as => Integer
  xml_reader :idref, :from => :attr, :as => Integer
  xml_reader :colref, :from => :attr, :as => Integer
  xml_reader :properties, :as => [Property]
  xml_reader :schema, :required => true, :as => Schema
  xml_reader :query, :required => true, :cdata => true
end

class Query_Plan_Bundle
  include ROXML

  xml_reader :query_plan, :required => true, :as => [QueryPlan]
end

end
