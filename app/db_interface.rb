require 'sinatra/activerecord'

# nodoc
module Db
  def self.init_connection
    ActiveRecord::Base.logger = Logger.new(STDOUT)
  end
end
