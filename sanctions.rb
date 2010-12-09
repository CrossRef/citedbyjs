require 'rubygems'
require 'sinatra/base'
require 'dm-core'

module Sinatra
  module Sanctions
    module Helpers

      def credence?(data)
        Credence.count(:to => data) > 0
      end

      def credence!(data, s)
        c = Credence.first_or_create({:to => data}, {:when => Time.now, :sanction => s})
        c.save
      end

      def get_credentials(data)
        sanction = nil

        if credence?(data) then
          c = Credence.first(:to => data)
          sanction = c.sanction
        else
          sanction_name = data_to_sanctionable_name(data)
          sanction = Sanction.first(:name => sanction_name)
          credence!(data, sanction)
        end
        
        if sanction then
          return {:username => sanction.username, 
                  :password => sanction.password,
                  :sanctioned => true}
        else
          return {:sanctioned => false}
        end
      end

    end

    def self.registered(app)
      app.helpers Sanctions::Helpers
    end
  end
    
  register Sanctions
end

class Credence
  include DataMapper::Resource
  
  property :id, Serial, :required => true
  property :to, Text, :required => true, :unique_index => true
  property :when, DateTime, :required => true

  belongs_to :sanction
end

class Sanction
  include DataMapper::Resource
  
  property :id, Serial, :required => true
  property :name, String, :required => true, :unique_index => true
  property :username, String, :required => true
  property :password, String, :required => true

  has n, :credences
end
