require 'sinatra/activerecord'

# nodoc
module Db
  def self.init_connection
    # if ENV['RACK_ENV'] == 'production'
    #   ActiveRecord::Base.establish_connection(
    #     'postgres://myuser:mypass@localhost/somedatabase'
    #   )
    # else
    #   ActiveRecord::Base.establish_connection(
    #     adapter: 'sqlite3', database: 'db.sqlite3'
    #   )
    # end

    ActiveRecord::Base.logger = Logger.new(STDOUT)
  end
end
