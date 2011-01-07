class LinkProcessor < ActiveMessaging::Processor
  require 'net/http'
  
  subscribes_to :links
  publishes_to :dead_letter
  
  def on_error(err)
    if (err.kind_of?(StandardError))
      logger.error "ApplicationProcessor::on_error: #{err.class.name} rescued:\n" + \
      err.message + "\n" + \
      "\t" + err.backtrace.join("\n\t")
    else
      logger.error "ApplicationProcessor::on_error: #{err.class.name} raised: " + err.message
      raise err
    end
  end
  
  def on_message(message)
    begin
      logger.info("Processing message #{message}")
      link = Link.find(message)
      logger.info(link)
      
      result = fetch(link.uri)
      
      ##Parse Title and body summary
      doc = Nokogiri::HTML::Document.parse(result.body)
      link.name = parse_text(doc.xpath("//title").to_s, 255)
      link.description = parse_text(doc.xpath("//body").to_s, 500)
      link.processed = true
      
      ##Save
      link.save
    rescue Exception => e
      logger.error(e)
      publish :dead_letter, "#{message}\0"
      
      raise ActiveMessage::AbortMessageException
    end    
  end
  
  def fetch(uri_str, limit = 10)
    raise ArgumentError, 'HTTP redirect too deep' if limit == 0
    
    url = URI.parse(uri_str)    
    http = Net::HTTP.new(url.host, url.port)
    if(url.port == 443)
      http.use_ssl = true
    end
    
    response = http.get(url.path)
    case response
    when Net::HTTPSuccess then response
    when Net::HTTPRedirection then fetch(response['location'], limit - 1)
    else
      response.error!
    end
  end
  
  ## Parse html and crap out of text to max_length
  def parse_text(text, max_length)
    ## Strip html
    Sanitize::clean!(text, :remove_contents => ['script','style'])
    text.gsub!(/[\n\t]+/, ' ')
    if(text.size > max_length)
      count = max_length
      if text.size < count
        count = text.size-1
      end
      ## Parse backwards to the first space
      while text[count] != 32
        count = count - 1
      end
      new_text = text[0..count-1]
      return new_text
    else
      return text
    end
  end
end