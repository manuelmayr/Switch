module Switch
  require "active_record"
  # In version 3.0.0 (and higher)
  # of activerecord the
  # const_missing-method was overwritten
  # such it doesn't call legacy code anymore.
  # Due to the autoload feature of active_record
  # this happens when we access ActiveRecord::Base.
  # Here we ensure that we load Base before
  # we load our core_extensions into the heap.
  if ActiveRecord::VERSION::MAJOR >= 3 then
    ActiveRecord::Base
  end
  require "singleton"
  require "locomotive"
  require "switch/dispatcher.rb"
  require "switch/query_language"
  require "switch/inferences"
  require "switch/translation"
  require "pathfinder"
  require "switch/engines"
  require "switch/core_extensions"

  FERRY_CORE_VERSION="0.0.1"
end
