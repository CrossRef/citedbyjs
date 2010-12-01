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
  citations = getCitationsFor(doi)[:citations]
  if citations.length == 0 then
    haml :citations_none
  else 
    haml :citations_list
  end
end

def getCitationsFor(doi)
  unixref = Net::HTTP.get "doi.crossref.org",
      "/servlet/getForwardLinks" +
      "?doi=#{doi}" +
      "&usr=user" +
      "&pwd=password"
  unixref_doc = Document.new unixref

  jsonTop = {:citations => []}

  unixref_doc.elements.each("*/journal_cite") do |elem|
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
  elem.elements.each("contributors/author") do |author|
    authors += author.text + ", "
  end
  authors
end

def getDoi(elem)
  elem.elements["doi"].text
end
