require 'rubygems'
require 'sinatra'
require 'rexml/document'
require 'net/http'
require 'cgi'
require 'json'
include REXML

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

def getJournalTitle(elem) do
  elem.elements["journal_title"].text
end

def getTitle(elem) do
  elem.elements["article_title"].text
end

def getYear(elem) do
  elem.elements["year"].text
end

def getAuthors(elem) do
  authors = ""
  elem.elements.each("contributors/author") do |author|
    authors += author.text + ", "
  end
  authors
end

def getDoi(elem) do
  elem.elements["doi"].text
end
