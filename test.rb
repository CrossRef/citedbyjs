require 'rubygems'
require 'rspec'
require 'rack/test'
require 'dm-core'
require 'dm-migrations'
require 'citedby'

set :environment, :test

describe 'Cited-by widget server' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:all) do
    @db_config = YAML.load_file "#{Dir.pwd}/config/database.yaml"
    DataMapper.finalize
    DataMapper.setup(:default, @db_config['db'])

    @sanctioned_doi = "10.1371/journal.pone.0005723"
    @unsanctioned_doi = "10.1093/elt/ccp082"
    @non_existant_doi = "10.5555/does_not_exist"
  end

  before(:each) do
    DataMapper.auto_migrate!
    @sanction = Sanction.create(:name => "10.1371", :username => "plos", :password => "plos1")
  end

  after(:all) do
    # Clear the database (in case it is immediately used for production.)
    DataMapper.auto_migrate!
  end

  it "returns error for an unsanctioned DOI" do
    get "/#{@unsactioned_doi}"
    last_response.body.should include 'citedby-error'
  end

  it "returns success for a sanctioned DOI without credence" do
    get "/#{@sactioned_doi}"
    last_response.body.should include 'citedby-citations'
  end

  it "returns success for a sanctioned DOI with credence" do
    Credence.create(:to => @sanctioned_doi, :when => Time.now, :sanction => @sanction)
    get "/#{@sactioned_doi}"
    last_response.body.should include 'citedby-citations'
  end

  it "gives crecence on the first encounter of a sanctioned DOI" do
    get "/#{@sactioned_doi}"
    assert(Credence.count(:to => @sanctioned_doi) > 0)
  end

  it "returns error for a DOI without credence or sanction" do
    get "/#{@unsactioned_doi}"
    last_response.body.should include 'citedby-error'
  end

  it "returns error for a DOI with credence but invalid sanction credentials" do
    @sanction.password = 'invalid_password'
    @sanction.save

    get "/#{@sactioned_doi}"
    last_response.body.should include 'citedby-error'
  end

  it "returns error for a non-existant DOI" do
    get "/#{@non_existant_doi}"
    last_response.body.should include 'citedby-error'
  end
end
