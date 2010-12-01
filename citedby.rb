require 'rubygems'
require 'sinatra'
require 'rexml/document'
require 'net/http'
require 'cgi'
require 'json'
include REXML

get '/*', :provides => :json do
  doi = params['splat'].join('/')
  doi = CGI.unescape(doi)
  JSON.dump getCitationsFor(doi)
end

get '/*' do
  doi = params['splat'].join('/')
  doi = CGI.unescape(doi)
  haml :citations, :locals => {:citations => getCitationsFor(doi)[:citations]}
end

def getCitationsFor(doi)
  unixref = Net::HTTP.get "doi.crossref.org",
      "/servlet/getForwardLinks" +
      "?doi=#{doi}" +
      "&usr=" +
      "&pwd="
  unixref_doc = Document.new unixref

  jsonTop = {:citations => []}

  unixref_doc.elements.each("//journal_cite") do |elem|
    citation = { 
      :journal_title => getJournalTitle(elem),
      :title => getTitle(elem),
      :year => getYear(elem),
      :authors => getAuthors(elem),
      :doi => getDoi(elem)
    }

    jsonTop[:citations] << citation
  end

  jsonTop
end

def getJournalTitle(elem)
  elem.elements["journal_title"].text
end

def getTitle(elem)
  elem.elements["article_title"].text
end

def getYear(elem)
  elem.elements["year"].text
end

def getAuthors(elem)
  authors = ""
  elem.elements.each("contributors/contributor") do |author|
    authors += author.elements["given_name"].text + " "
    authors += author.elements["surname"].text + ", "
  end
  authors
end

def getDoi(elem)
  elem.elements["doi"].text
end
