class Link < ActiveRecord::Base
  require 'digest/sha1'

  has_many :comments, :class_name => "Comment", :foreign_key => "link_id"
  
  def upvote
    redis.incr("#{key}:votes")
  end
  
  def downvote
    redis.decr("#{key}:votes")
  end
  
  def votes
    votes = redis.get("#{key}:votes")
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

  private
  def redis
    Redis.connect(:url => REDIS_HOST)
  end
  
  def key
    Digest::SHA1.hexdigest(self.uri)
  end
end
