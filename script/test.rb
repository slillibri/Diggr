#!/usr/bin/env ruby

require 'rss_parser.rb'

tags = ['bind']

tags.each do |tag|
  puts "Processing #{tag}"
  data = []
  ## Fetch first page, determine total pages
  doc = Nokogiri::HTML(open("http://serverfault.com/questions/tagged/#{tag}"))

  pager = doc.xpath('//div[@class="pager fl"]')
  pages = pager.xpath('//span[@class="page-numbers"]').last.text.to_i
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
  File.open("test/data/serverfault_#{tag}.yml", 'w') {|f| f.write(YAML::dump(data))}
  puts "Done (#{data.count} links)"
end
