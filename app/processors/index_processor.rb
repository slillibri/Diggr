class IndexProcessor < ActiveMessaging::Processor
  subscribes_to :index
  
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
      rsolr = RSolr.connect(:url => RSOLR_SERVER)
      doc = {:uri => link.uri, :name => link.name, :id => link.id, :description => link.description, :created_at => link.created_at.strftime("%Y-%m-%dT%H:%M:%SZ")}
      rsolr.add(doc)
      rsolr.commit
    rescue Exception => e
      logger.error(e.message)
      logger.error(e.backtrace.join("\n"))
      raise ActiveMessaging::AbortMessageException
    end
    
  end
end