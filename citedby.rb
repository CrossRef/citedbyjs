require 'rubygems'
require 'sinatra'
require 'rexml/document'
require 'net/http'
require 'cgi'
require 'json'
include REXML

get '/test/*' do
  JSON.dump({
    :citations => [ 
                   { 
                     :title => "Article 1",
                     :journal_title => "Journal Title",
                     :year => "2010",
                     :authors => "A. Name, Another Name",
                     :doi => "10.10/blah"
                   },
                   {
                     :title => "Article 2",
                     :journal_title => "Journal Title",
                     :year => "2009",
                     :authors => "A. Name, Another Name",
                     :doi => "10.10/blah2"
                   }
                  ]
  })
end

get '/*' do
  doi = params['splat'].join('/')
  doi = CGI.unescape(doi)
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
  
  JSON.dump jsonTop
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
