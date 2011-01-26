#!/usr/bin/env ruby

require 'rubygems'
require 'rss_parser'
require 'getopt/long'
require 'pp'

opts = Getopt::Long.getopts(
  ['--debug', '-d', Getopt::BOOLEAN],
  ['--max-pages', '-m', Getopt::REQUIRED])

opts['m'] = 25 unless opts['m']
opts['dest-dir'] = '../' unless opts['dest-dir']

pp opts if opts['d']

## Gather popular tags (first page)
doc = Nokogiri::HTML(open('http://serverfault.com/tags'))
links = doc.xpath('//a[@class="post-tag"]')
tags = []
links.each {|link| 
  tag = link.children.first.text
  tags << tag if tag.size > 0
  puts "Adding #{tag}" if opts["d"]
}

puts "Processing #{tags.count} tags" if opts['d']

tags.each do |tag|
  puts "Processing #{tag}"
  data = []
  ## Fetch first page, determine total pages
  doc = Nokogiri::HTML(open("http://serverfault.com/questions/tagged/#{tag}"))
  pager = doc.xpath('//div[@class="pager fl"]')
  pages = pager.xpath('//span[@class="page-numbers"]').last.text.to_i
  pages = opts["m"].to_i if pages > opts["m"].to_i
  puts "Fetching #{opts['m']} pages instead of #{pages} because of --max-pages option" if opts["d"]
  
  puts "Processing #{pages} pages for tag #{tag}"
  
  (1..pages).each do |page|
    p = ParseRss.new("http://serverfault.com/feeds/tag/#{tag}?page=#{page}")
    links = p.parse
    if links.size == 0
      break
    end
    
    data = data.concat(p.parse)
    printf("Page %d (%d links)...  ", page, data.count)
    STDOUT.flush
  end
  File.open("#{opts['dest-dir']}/test/data/serverfault_#{tag}.yml", 'w') {|f| f.write(YAML::dump(data))}
  puts "Done (#{data.count} links)"
end
