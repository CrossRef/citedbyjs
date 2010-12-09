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

  cite_types = [ { :elem => 'journal_cite',
                   :fn => method(:parse_journal_cite) },
                 { :elem => 'conf_cite',
                   :fn => method(:parse_standard_cite) },
                 { :elem => 'book_cite',
                   :fn => method(:parse_standard_cite) },
                 { :elem => 'dissertation_cite',
                   :fn => method(:parse_dissertation_cite) },
                 { :elem => 'report_cite',
                   :fn => method(:parse_standard_cite) },
                 { :elem => 'standard_cite',
                   :fn => method(:parse_standard_cite) },
                 { :elem => 'database_cite',
                   :fn => method(:parse_database_cite) } ]

  cite_types.each do |cite_type|
    unixref_doc.elements.each("//" + cite_type[:elem]) do |elem|
      jsonTop[:citations] << cite_type[:fn].call(elem)
    end
  end

  jsonTop
end

def parse_journal_cite(elem)
  {
    :container_title => elem.elements['journal_title'].text,
    :work_title => elem.elements['article_title'].text,
    :year => elem.elements['year'].text,
    :authors => get_authors(elem),
    :doi => elem.elements['doi'].text
  }
end

def parse_database_cite(elem)
  {
    :work_title => elem.elements['title'].text,
    :container_title => elem.elements['institution_name'].text,
    :year => elem.elements['year'].text,
    :authors => get_authors(elem),
    :doi => elem.elements['doi'].text
  }
end

def parse_dissertation_cite(elem)
  {
    :work_title => elem.elements['title'].text,
    :container_title => elem.elements['institution_name'].text,
    :year => elem.elements['year'].text,
    :authors => get_authors(elem),
    :doi => elem.elements['doi'].text
  }
end

def parse_standard_cite(elem)
  {
    :work_title => elem.elements['volume_title'].text,
    :container_title => elem.elements['series_title'].text,
    :year => elem.elements['year'].text,
    :authors => get_authors(elem),
    :doi => elem.elements['doi'].text
  }
end

def get_authors(elem)
  authors = ""
  elem.elements.each("contributors/contributor") do |author|
    authors += author.elements["given_name"].text + " "
    authors += author.elements["surname"].text + ", "
  end
  authors
end
  
