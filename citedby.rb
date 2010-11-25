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
                               :title => "Single molecule force spectroscopy by AFM indicates helical structure of poly(ethylene-glycol) in water",
                               :journal_title => "New Journal of Physics",
                               :year => "1999",
                               :authors => "F Oesterhelt, M Rief and H E Gaub",
                               :doi => "10.1088/1367-2630/1/1/006"
                             },
                             {
                               :title => "Metal nanoparticles and their assemblies",
                               :journal_title => "Chemical Society Reviews",
                               :year => "2000",
                               :authors => "C. N. Ramachandra Rao, Giridhar U. Kulkarni, P. John Thomas and Peter P. Edwards",
                               :doi => "10.1039/a904518j"
                             },
                             { 
                               :title => "Single molecule force spectroscopy by AFM indicates helical structure of poly(ethylene-glycol) in water",
                               :journal_title => "New Journal of Physics",
                               :year => "1999",
                               :authors => "F Oesterhelt, M Rief and H E Gaub",
                               :doi => "10.1088/1367-2630/1/1/006"
                             },
                             {
                               :title => "Metal nanoparticles and their assemblies",
                               :journal_title => "Chemical Society Reviews",
                               :year => "2000",
                               :authors => "C. N. Ramachandra Rao, Giridhar U. Kulkarni, P. John Thomas and Peter P. Edwards",
                               :doi => "10.1039/a904518j"
                             },
                             { 
                               :title => "Single molecule force spectroscopy by AFM indicates helical structure of poly(ethylene-glycol) in water",
                               :journal_title => "New Journal of Physics",
                               :year => "1999",
                               :authors => "F Oesterhelt, M Rief and H E Gaub",
                               :doi => "10.1088/1367-2630/1/1/006"
                             },
                             {
                               :title => "Metal nanoparticles and their assemblies",
                               :journal_title => "Chemical Society Reviews",
                               :year => "2000",
                               :authors => "C. N. Ramachandra Rao, Giridhar U. Kulkarni, P. John Thomas and Peter P. Edwards",
                               :doi => "10.1039/a904518j"
                             },
                             { 
                               :title => "Single molecule force spectroscopy by AFM indicates helical structure of poly(ethylene-glycol) in water",
                               :journal_title => "New Journal of Physics",
                               :year => "1999",
                               :authors => "F Oesterhelt, M Rief and H E Gaub",
                               :doi => "10.1088/1367-2630/1/1/006"
                             },
                             {
                               :title => "Metal nanoparticles and their assemblies",
                               :journal_title => "Chemical Society Reviews",
                               :year => "2000",
                               :authors => "C. N. Ramachandra Rao, Giridhar U. Kulkarni, P. John Thomas and Peter P. Edwards",
                               :doi => "10.1039/a904518j"
                             },
                             { 
                               :title => "Single molecule force spectroscopy by AFM indicates helical structure of poly(ethylene-glycol) in water",
                               :journal_title => "New Journal of Physics",
                               :year => "1999",
                               :authors => "F Oesterhelt, M Rief and H E Gaub",
                               :doi => "10.1088/1367-2630/1/1/006"
                             },
                             {
                               :title => "Metal nanoparticles and their assemblies",
                               :journal_title => "Chemical Society Reviews",
                               :year => "2000",
                               :authors => "C. N. Ramachandra Rao, Giridhar U. Kulkarni, P. John Thomas and Peter P. Edwards",
                               :doi => "10.1039/a904518j"
                             }
                            ],
              :has_more => true
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
