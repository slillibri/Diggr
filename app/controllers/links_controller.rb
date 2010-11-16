class LinksController < ApplicationController
  before_filter :authenticate_user!, :except => ['index', 'show']
  
  # GET /links
  # GET /links.xml
  def index
    @links = Link.all(:order => 'created_at desc', :limit => 20)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @links }
    end
  end

  # GET /links/1
  # GET /links/1.xml
  def show
    @link = Link.find(params[:id])

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
      if @link.save
        format.html { redirect_to(@link, :notice => 'Link was successfully created.') }
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
        format.html { redirect_to(@link, :notice => 'Link was successfully updated.') }
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
end
