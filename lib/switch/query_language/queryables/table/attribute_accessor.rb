module Switch

  class AttributeAccessor < Queryable
    attributes :queryable,
               :attr

    def initialize(queryable, attr_name)
      @queryable = StandardWrapper::wrap queryable

      attr_name_ = Queryable === attr_name ? attr_name :
                                        attr_name.to_sym
      @attr = StandardWrapper::wrap attr_name_
    end
  end

end
