module Switch

  # general error for unspecified translation fault
  class TranslationError < StandardError; end

  # if an attribute could not be found
  class AttributeNotFoundError < TranslationError; end
  # type not found in schema
  class TypeNotFoundError < TranslationError; end

end
