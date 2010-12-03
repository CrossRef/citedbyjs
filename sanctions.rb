require 'rubygems'
require 'sinatra/base'
require 'dm-core'

module Sinatra
  module Sanctions
    module Helpers

      def sanctioned?(data)
        sanction_name = options.data_to_sanction_name.call(data)
        Sanction.count(:name => sanction_name) > 0
      end

      def has_credence?(data)
        Credence.count(:to => data)
      end

      def give_credence!(data)
        s = Credence.first_or_create({:to => data}, {:when => Time.now})
        s.save
      end
                                       
    end

    def self.registered(app)
      app.helpers Sanctions::Helpers

      app.set :data_to_sanction_name, lambda { return "" }
    end
  end
    
  register Sanctions
end

class Credence
  include DataMapper::Resource
  
  property :id, Serial, :required => true
  property :to, Text, :required => true, :unique_index => true
  property :when, Date, :required => true
end

class Sanction
  include DataMapper::Resource
  
  property :id, Serial, :required => true
  property :name, String, :required => true, :unique_index => true
  property :username, String, :required => true
  property :password, String, :required => true
end
