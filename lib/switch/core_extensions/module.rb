module Switch

  # extensions to enhance an object with some attributes
  # and derive simple methods
  module ModuleExtensions
    private

    def derive(method_name)
      methods = {
        :initialize => "
           def #{method_name}(#{@attributes.join(',')})
             #{@attributes.collect { |a| "@#{a} = #{a}" }.join("\n")}
           end",
        :== => "
           def ==(other)
             #{name} === other &&
             #{@attributes.collect { |a| "@#{a} == other.#{a}" }.join(" &&\n")}
           end"
      }
      class_eval methods[method_name], __FILE__, __LINE__
    end

    public

    # extend the instance with some new attributes
    def attributes(*attrs)
      @attributes = attrs
      attr_reader(*attrs)
    end

    def deriving(*methods)
      methods.each(&method(:derive))
    end

    # stolen from active_support
    # reimplement it by time since it use deprecated string metaprogramming
    def delegate(*methods)
      options = methods.pop
      unless options.is_a?(Hash) && to = options[:to]
        raise ArgumentError, "Delegation needs a target. Supply an options hash with a :to key as the last argument (e.g. delegate :hello, :to => :greeter)."
      end

      if options[:prefix] == true && options[:to].to_s =~ /^[^a-z_]/
        raise ArgumentError, "Can only automatically set the delegation prefix when delegating to a method."
      end

      prefix = options[:prefix] && "#{options[:prefix] == true ? to : options[:prefix]}_"

      file, line = caller.first.split(':', 2)
      line = line.to_i

      methods.each do |method|
        on_nil =
          if options[:allow_nil]
            'return'
          else
            %(raise "#{self}##{prefix}#{method} delegated to #{to}.#{method}, but #{to} is nil: \#{self.inspect}")
          end

        module_eval(<<-EOS, file, line)
          def #{prefix}#{method}(*args, &block)               # def customer_name(*args, &block)
            #{to}.__send__(#{method.inspect}, *args, &block)  #   client.__send__(:name, *args, &block)
          rescue NoMethodError                                # rescue NoMethodError
            if #{to}.nil?                                     #   if client.nil?
              #{on_nil}
            else                                              #   else
              raise                                           #     raise
            end                                               #   end
          end                                                 # end
        EOS
      end
    end

    def methify
      Inflector::underscore(
        self.name.split("::").last).to_sym
    end

    Module.send :include, self
  end

end

class Module
  alias :const_missing_ :const_missing
  def const_missing(const)
      if ::Switch::Queryable.engine and
         ::Switch::Queryable.engine.tables.member? const.to_s.downcase then
        ::Switch::Table(const.to_s.downcase.to_sym)
      else
        const_missing_(const)
      end
  end
end


