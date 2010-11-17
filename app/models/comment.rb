class Comment < ActiveRecord::Base
  belongs_to :link, :class_name => "Link", :foreign_key => "link_id"
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  
  acts_as_tree :order => 'created_at'
  
  before_save :calculate_depth
  
  private
  def calculate_depth
    unless self.parent.nil?
      self.depth = self.ancestors.count
    end
  end
end
