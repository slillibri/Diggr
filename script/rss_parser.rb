#!/usr/bin/env ruby
require 'rubygems'
require 'rexml/document'
require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'sanitize'
require 'yaml'
require 'time'

class ParseRss
	def initialize(url)
		@url = url
	end
	
	def parse
		@content = Net::HTTP.get(URI.parse(@url))
		xml = REXML::Document.new(@content)
		data = []
		xml.elements.each('//entry') do |item|
			it = {
  			:name => item.elements['title'].text,
  			:uri =>  item.elements['id'].text,
  			:description => parse_text(item.elements['summary'].text),
  			:created_at => Time.parse(item.elements['published'].text),
  			:tag_list => []
		  }
		  item.elements.each('.//category') do |category|
		    it[:tag_list] << category.attributes['term']
	    end
			data << it
		end
		data
	end
	
	def parse_text(text)
    ## Strip html
    Sanitize::clean!(text, :remove_contents => ['script','style'])
    text.gsub!(/[\n\t\s]+/, ' ')
    return text
  end
end
