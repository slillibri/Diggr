class Link < ActiveRecord::Base
  require 'digest/sha1'
  include ActiveMessaging::MessageSender
  publishes_to :index
  
  has_many :comments, :class_name => "Comment", :foreign_key => "link_id"

  acts_as_taggable
  
  searchable :auto_index => false do
    text :name
    text :description
  end
  
  after_save :index
  after_create :index
  
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

  def index
    publish :index, "#{self.id}\0"
  end

  private
  def redis
    Redis.connect(:url => REDIS_HOST)
  end
  
  def key
    Digest::SHA1.hexdigest(self.uri)
  end
  
end
