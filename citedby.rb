require 'rubygems'
require 'sinatra'
require 'rexml/document'
require 'net/http'
require 'cgi'
require 'json'
require 'dm-core'
require 'dm-migrations'
require 'haml'
require 'sanctions.rb'
include REXML

unsanctioned_doi = "The owner of this DOI has not " \
                        + "sanctioned the use of the Cited-by widget " \
                        + "for their content."

configure do
  @db_config = YAML.load_file "#{Dir.pwd}/config/database.yaml"
  DataMapper.finalize
  DataMapper.setup(:default, @db_config['db'])
  DataMapper.auto_upgrade!
end

def data_to_sanctionable_name(doi)
  unixref = Net::HTTP.get "www.crossref.org",
      "/openurl/?id=doi:#{doi}" +
      "&noredirect=true" +
      "&pid=kward@crossref.org" +
      "&format=unixref"
  unixref_doc = Document.new unixref

  unixref_doc.elements["//doi_record"].attributes["owner"]
end

get '/*', :provides => :json do
  doi = params['splat'].join('/')
  c = get_credentials doi

  if c[:sanctioned] then
    doi = CGI.unescape doi
    JSON.dump get_citations(doi, c)
  else 
    JSON.dump({:error => unsanctioned_doi})
  end
end

get '/*' do
  doi = params['splat'].join('/')
  c = get_credentials doi

  if c[:sanctioned] then
    doi = CGI.unescape doi
    haml :citations, :locals => {:citations => get_citations(doi, c)[:citations]}
  else
    haml :error, :locals => {:error_message => unsanctioned_doi}
  end
end

def get_citations(doi, credentials)
  unixref = Net::HTTP.get "doi.crossref.org",
      "/servlet/getForwardLinks" +
      "?doi=#{doi}" +
      "&usr=#{credentials[:username]}" +
      "&pwd=#{credentials[:password]}"
  unixref_doc = Document.new unixref

  jsonTop = {:citations => []}

  unixref_doc.elements.each("//journal_cite") do |elem|
    citation = { 
      :journal_title => get_journal_title(elem),
      :title => get_title(elem),
      :year => get_year(elem),
      :authors => get_authors(elem),
      :doi => get_doi(elem)
    }

    jsonTop[:citations] << citation
  end

  jsonTop
end

def get_journal_title(elem)
  elem.elements["journal_title"].text
end

def get_title(elem)
  elem.elements["article_title"].text
end

def get_year(elem)
  elem.elements["year"].text
end

def get_authors(elem)
  authors = ""
  elem.elements.each("contributors/contributor") do |author|
    authors += author.elements["given_name"].text + " "
    authors += author.elements["surname"].text + ", "
  end
  authors
end

def get_doi(elem)
  elem.elements["doi"].text
end
