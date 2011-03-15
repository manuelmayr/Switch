module Switch

  module Dispatcher
    def dispatch(klass, *params)
      klass.ancestors.each do |kl|
        type = kl.methify

        if self.respond_to? type then
           return self.send(type, *params)
        end
      end

      raise StandardError, "rule for #{klass.ancestors} doesn't exist"
    end
  end

end
