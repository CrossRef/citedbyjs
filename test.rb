require 'rubygems'
require 'rspec'
require 'rack/test'
require 'citedby'

set :environment, :test

describe 'Cited-by Services' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "Returns error for an unsanctioned DOI" do
    
  end

  it "Returns success for a sanctioned DOI without credence" do
  end

  it "Returns success for a sanctioned DOI with credence" do
  end

  it "Gives crecence on the first encounter of a sanctioned DOI" do
  end

  it "Returns error for a DOI with credence but invalid sanction credentials" do
  end

  it "Returns error for a non-existant DOI" do
  end
end
