module Switch

  class Table < Queryable
    attributes :name,
               :attributes,
               :keys,
               :order

    def initialize(name, attributes, options = {})
      @name = name.to_s
      @attributes = attributes.map do |attr, type|
                                 [StandardWrapper::wrap(attr), type]
                               end.to_hash
      keys = options[:keys]
      @keys = keys.nil? ? [] : keys.map { |key| StandardWrapper::wrap key }
      order = options[:order]
      @order = order.nil? ? [] : order.map { |ord| StandardWrapper::wrap ord }
      @order = @keys if @order.empty?
    end

  end

end
