module Switch
  def self.Table(name, options={})
    attributes = Queryable.engine.
                           columns(name.to_sym).map do |attr|
                   [attr.name.to_sym,attr.type]
                 end
    # mapping from database types to appropriate
    # types in the relational algebra
    type_mapping = { :integer => TInt.type,
                     :string  => TStr.type,
                     :text    => TStr.type,
                     :float   => TDbl.type,
                     :decimal => TDbl.type,
                     :datetime => TStr.type,
                     :timestamp => TStr.type,
                     :boolean  => TInt.type }

    # get primary keys from the database table
    primary_key = Queryable.engine.primary_key(name.to_s)

    options[:keys]  = [primary_key ? primary_key.to_sym :
                                     attributes.first.first] if options[:keys].nil?

    Table.new(name.to_sym,
              attributes.map do |a,t|
                 [a,type_mapping[t]]
              end, options)
  end
end
