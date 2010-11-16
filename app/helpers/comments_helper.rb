module CommentsHelper  
  def format_comment(comment)
    logger.warn("#{comment.id} : #{comment.parent_id} : #{comment.depth}")
    span = 24 - comment.depth
    desc = span - comment.depth - 4
    render :partial => 'comments/comment',
           :locals => {:comment => comment, :span  => span, :offset => comment.depth, :desc => desc}
  end
end
