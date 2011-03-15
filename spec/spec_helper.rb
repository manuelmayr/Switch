dir = File.dirname(__FILE__)
$LOAD_PATH.unshift "#{dir}/../lib"

require "spec"
require "switch"

[:matchers].each do |helper|
  Dir["#{dir}/#{helper}/*"].each { |m| require "#{dir}/#{helper}/#{File.basename(m)}" }
end

module AdapterGuards
  def adapter_is(name)
      verify_adapter_name(name)
      yield if name.to_s == adapter_name
  end

  def adapter_is_not(name)
    verify_adapter_name(name)
    yield if name.to_s != adapter_name
  end

  def adapter_name
    name = ActiveRecord::Base.configurations["unit"][:adapter]
    verify_adapter_name(name)
    name
  end

  def verify_adapter_name(name)
    raise "Invalid adapter name: #{name}" unless valid_adapters.include?(name.to_s)
  end

  def valid_adapters
    %w[ibm_db postgresql]
  end
end

# force stdout stream to flush after every print
STDOUT.sync = true


Spec::Runner.configure do |config|
  config.include SQLMatcher
  config.include AdapterGuards

  config.before do
    # setting up an appropriate Engine
    Switch::Queryable.engine =
       Switch::Engine.new ActiveRecord::Base
  end
end
