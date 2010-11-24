class TagsController < ApplicationController
  before_filter :authenticate_user!
  
  def new
    @link = Link.find(params[:id])
  end
  
  def create
    @link = Link.find(params[:tag][:link])
    if @link.tag_list.include?(params[:tag][:name])
      flash[:notice] = "This link is already tagged with #{params[:tag][:name]}"
      redirect_to :controller => 'links', :action => 'show', :id => @link and return
    end
    @link.tag_list.push(params[:tag][:name])

    respond_to do |format|
      if @link.save!
        flash[:notice] = 'Added Tag'
        format.html {redirect_to :controller => 'links', :action => 'show', :id => @link}
      else
        format.html {render :new, :link => @link}
      end
    end
  end
end
