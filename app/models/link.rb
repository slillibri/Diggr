class Link < ActiveRecord::Base
  require 'digest/sha1'
  include ActiveMessaging::MessageSender
  publishes_to :index
  
  has_many :comments, :class_name => "Comment", :foreign_key => "link_id"

  acts_as_taggable
  
  #after_save :index
  
  cattr_reader :per_page
  @@per_page = 10
  
  def upvote
    redis.incr("#{key}:votes")
  end
  
  def downvote
    redis.decr("#{key}:votes")
  end
  
  def votes
    votes = redis.get("#{key}:votes").to_i
    votes ||= 0
    votes
  end
  
  def voters
    voters = redis.smembers("#{key}:voters")
    voters ||= []
    voters
  end
  
  def add_voter(user)
    redis.sadd("#{key}:voters", user.user_name)
  end

  def index
    publish :index, "#{self.id}\0"
  end

  def score
    begin
      if redis.exists("#{key}:score")
        logger.debug("Returning score from Redis")
        return redis.get("#{key}:score")
      end
      ts = self.created_at.strftime('%s').to_i - Time.parse(TSTART).strftime('%s').to_i
      y = 1
      if self.votes == 0
        y = 0
      elsif self.votes < 0
        y = -1
      end
    
      z = self.votes.abs
      logger.debug("Math.log10(#{z}) * ((#{y} * #{ts})/45000)")
      score = Math.log10(z) * ((y*ts)/45000)
      redis.set("#{key}:score", score)
      redis.expire("#{key}:score", Time.now.strftime('%s').to_i + 3600)

      return score
    rescue Exception => e
      puts "Huston we have a problem"
      puts "#{e.message}"
      puts e.backtrace.join("\n")
    end
  end
  
  private
  def redis
    Redis.connect(:url => REDIS_HOST)
  end
  
  def key
    Digest::SHA1.hexdigest(self.uri)
  end
  
end
