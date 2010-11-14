class UrlsController < ApplicationController
  before_filter :authenticate_user!, :except => ['index', 'show']
  
  # GET /urls
  # GET /urls.xml
  def index
    @urls = Url.all(:order => 'created_at desc', :limit => 20)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @urls }
    end
  end

  # GET /urls/1
  # GET /urls/1.xml
  def show
    @url = Url.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @url }
    end
  end

  # GET /urls/new
  # GET /urls/new.xml
  def new
    @url = Url.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @url }
    end
  end

  # GET /urls/1/edit
  def edit
    @url = Url.find(params[:id])
  end

  # POST /urls
  # POST /urls.xml
  def create
    @url = Url.new(params[:url].merge(:created_by => current_user))    
    respond_to do |format|
      if @url.save
        format.html { redirect_to(@url, :notice => 'Url was successfully created.') }
        format.xml  { render :xml => @url, :status => :created, :location => @url }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @url.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /urls/1
  # PUT /urls/1.xml
  def update
    @url = Url.find(params[:id])

    respond_to do |format|
      if @url.update_attributes(params[:url])
        format.html { redirect_to(@url, :notice => 'Url was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @url.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /urls/1
  # DELETE /urls/1.xml
  def destroy
    @url = Url.find(params[:id])
    @url.destroy

    respond_to do |format|
      format.html { redirect_to(urls_url) }
      format.xml  { head :ok }
    end
  end
  
  # GET /url/1/vote
  def vote
    @url = Url.find(params[:id])
    unless @url.voters.include?(current_user.user_name)
      if params[:vote] == 'upvote'
        if @url.upvote
          @url.add_voter(current_user)
        end
      else
        if @url.downvote
          @url.add_voter(current_user)
        end
      end
    else
      flash[:notice] = 'You voted on this already'
    end
    redirect_to :action => 'index'
  end
end
