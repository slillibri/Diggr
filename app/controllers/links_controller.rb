class LinksController < ApplicationController
  before_filter :authenticate_user!, :except => ['index', 'show']
  include ActiveMessaging::MessageSender
  publishes_to :links
  
  # GET /links
  # GET /links.xml
  def index
    @links = Link.all(:conditions => 'processed = 1', :order => 'created_at desc', :limit => 20)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @links }
    end
  end

  # GET /links/1
  # GET /links/1.xml
  def show
    @link = Link.find(params[:id])
    @comments = print_parents(@link)
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @link }
    end
  end

  # GET /links/new
  # GET /links/new.xml
  def new
    @link = Link.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @link }
    end
  end

  # GET /links/1/edit
  def edit
    @link = Link.find(params[:id])
  end

  # POST /links
  # POST /links.xml
  def create
    @link = Link.new(params[:link].merge(:created_by => current_user))    
    respond_to do |format|
      if @link.save!
        logger.warn("#{@link.id}")
        publish :links, "#{@link.id}\0"
        flash[:notice] = 'Link was successfully created.'
        format.html { redirect_to(@link) }
        format.xml  { render :xml => @link, :status => :created, :location => @link }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @link.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /links/1
  # PUT /links/1.xml
  def update
    @link = Link.find(params[:id])

    respond_to do |format|
      if @link.update_attributes(params[:link])
        flash[:notice] = 'Link was successfully updated.'
        format.html { redirect_to(@link) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @link.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /links/1
  # DELETE /links/1.xml
  def destroy
    @link = Link.find(params[:id])
    @link.destroy

    respond_to do |format|
      format.html { redirect_to(links_url) }
      format.xml  { head :ok }
    end
  end
  
  # GET /url/1/vote
  def vote
    @link = Link.find(params[:id])
    unless @link.voters.include?(current_user.user_name)
      if params[:vote] == 'upvote'
        if @link.upvote
          @link.add_voter(current_user)
        end
      else
        if @link.downvote
          @link.add_voter(current_user)
        end
      end
    else
      flash[:notice] = 'You voted on this already'
    end
    redirect_to :action => 'index'
  end
  
  def show_comments
    @link = Link.find(params[:id])    
  end
  
  private
  def print_parents(link)
    html = []
    parents = link.comments.select{|c| c.parent.nil? }
    parents.each do |parent|
      logger.debug("#{parent.id} : #{parent.parent_id} : #{parent.children.count}")
      html << render_to_string(:partial => 'comments/comment',
                               :locals => {:comment => parent, :span => 24, :offset => 0, :desc => 4, :highlight => (html.size % 2)})
      print_children(parent, html)
    end
    html
  end

  def print_children(parent, html)
    parent.children.each do |child|
      logger.debug("#{child.id} : #{child.parent_id} : #{child.children.count}")
      span = 24 - child.depth
      desc = span - child.depth - 4
      html << render_to_string(:partial => 'comments/comment',
                               :locals => {:comment => child, :span => span, :offset => child.depth, :desc => desc, :highlight => (html.size % 2)})
      if child.children.count > 0
        print_children(child, html)
      end
    end
  end  
end
