module Switch

  module Inflector
    extend self

    #  Converts the string to UpperCamelCase
    def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
      str = lower_case_and_underscored_word.to_s
      if first_letter_in_uppercase then
        str.gsub(/\/(.?)/) { "::#{$1.upcase}" }.
            gsub(/(?:^|_)(.)/) { $1.upcase }
      else
        str[0].chr.downcase +
               camelize(lower_case_and_underscored_word)[1..-1]
      end
    end

    # the reverse to camelcase
    def underscore(camel_cased_word)
      camel_cased_word.to_s.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
      downcase
    end

  end

end
