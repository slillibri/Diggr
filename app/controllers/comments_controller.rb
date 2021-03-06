class CommentsController < ApplicationController
  before_filter :authenticate_user!, :except => ['index','show']
  # GET /comments
  # GET /comments.xml
  def index
    @comments = Comment.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @comments }
    end
  end

  # GET /comments/1
  # GET /comments/1.xml
  def show
    @link = Link.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /comments/new
  # GET /comments/new.xml
  def new
    @comment = Comment.new
    @link = Link.find(params[:link])
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
  end

  # POST /comments
  # POST /comments.xml
  def create
    @link = Link.find(params[:comment].delete(:link))
    @comment = @link.comments.build(params[:comment].merge(:user => current_user))

    respond_to do |format|
      if @comment.save
        flash[:notice] = 'Comment was successfully created.'
        format.html { redirect_to(:controller => 'links', :id => @link) }
        format.xml  { render :xml => @comment, :status => :created, :location => @link }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        flash[:notice] = 'Comment was successfully updated.'
        format.html { redirect_to(@comment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to(comments_url) }
      format.xml  { head :ok }
    end
  end
  
  def reply
    @parent = Comment.find(params[:id])
    @comment = Comment.new
  end
  
  def create_reply
    @parent = Comment.find(params[:id])
    @comment = @parent.children.create(params[:comment].merge(:user => current_user, :link => @parent.link))
    
    respond_to do |wants|
      flash[:notice] = 'Comment was successfully created'
      wants.html { redirect_to(:controller => 'links', :action => 'show', :id => @parent.link) }
    end
  end
end
