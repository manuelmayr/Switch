puts "Using native PostgreSQL"
require "active_record"
require "logger"

ActiveRecord::Base.logger = Logger.new("debug.log")

ActiveRecord::Base.configurations = {
          'pg_unit' => {
            :username => 'mayr', # insert your username
            :adapter  => :postgresql,
            :encoding => 'utf8',
            :database => 'switch_unit' # insert your database
          }
}

print " - Establish connection ... "

ActiveRecord::Base.establish_connection 'pg_unit'

puts "done"
