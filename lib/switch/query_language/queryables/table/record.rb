module Switch

  class Record < Queryable
    attributes :attributes
    delegate :[],
             :map,
             :to => :attributes

    def initialize(attr_hash)
      @attributes = attr_hash.map do |k,v|
                      k_ = Queryable === k ? k : k.to_sym
                      [StandardWrapper::wrap(k_),
                       StandardWrapper::wrap(v)]
                    end.to_hash
    end

  end

end
