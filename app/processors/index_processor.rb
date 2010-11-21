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
      if(link.processed = 0)
        return
      end
      link.index!
    rescue Exception => e
      logger.error(e)
      raise ActiveMessaging::AbortMessageException
    end
    
  end
end