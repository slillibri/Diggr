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
		data = {}
		data['items'] = []
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
			data['items'] << it
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

## Gather popular tags (first page)
doc = Nokogiri::HTML(open('http://serverfault.com/tags'))
links = doc.xpath('//a[@class="post-tag"]')
tags = []
links.each {|link| 
  tag = link.children.first.text
  tags << tag if tag.size > 0
}

tags.each do |tag|
  puts "Processing #{tag}"
  p = ParseRss.new("http://serverfault.com/feeds/tag/#{tag}")
  data = p.parse
  File.open("/tmp/serverfault_#{tag}.yml", 'w') {|f| f.write(YAML::dump(data))}
  puts "Done"
end
