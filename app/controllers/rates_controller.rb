class RatesController < ApplicationController
  helper :users
  helper :sort
  include SortHelper
  helper :application

  before_action :require_admin_or_editable_role_permission
  before_action :require_user_id, only: %i[index new]
  before_action :set_project, only: %i[destroy]
  before_action :set_back_url

  VALID_SORT_OPTIONS = {
    'date_in_effect' => "#{Rate.table_name}.date_in_effect",
    'project_id' => "#{Project.table_name}.name"
  }.freeze

  # GET /rates?user_id=1
  # GET /rates.xml?user_id=1
  # GET /rates.json?user_id=1
  def index
    sort_init "#{Rate.table_name}.date_in_effect", 'desc'
    sort_update VALID_SORT_OPTIONS

    @rates = Rate.history_for_user(@user, sort_clause)
    @rate = Rate.new(project_id: params[:project_id], user_id: @user.id)
    @project = Project.find(params[:project_id])  rescue nil
    respond_to do |format|
      format.html { render action: 'index', layout: !request.xhr? }
      format.xml  { render xml: @rates }
      format.js
    end
  end

  # GET /rates/1
  # GET /rates/1.xml
  def show
    @rate = Rate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @rate }
    end
  end

  # GET /rates/new?user_id=1
  # GET /rates/new.xml?user_id=1
  def new
    @rate = Rate.new(user_id: @user.id)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @rate }
    end
  end

  # GET /rates/1/edit
  def edit
    @rate = Rate.find(params[:id])
  end

  # POST /rates
  # POST /rates.xml
  def create
    @rate = Rate.new(rate_params)

    respond_to do |format|
      if @rate.save

        unless Rate.rate_locking_enabled?
          ids =  Rate.where(date_in_effect: rate_params[:date_in_effect], project_id: @rate.project_id, user_id: @rate.user_id).ids
          current_rate_id = @rate.id
          skip_lock_feature_and_recalculate_cost!(ids, current_rate_id)
        end

        format.html do
          flash[:notice] = l(:rate_created_message)
          if User.current.allowed_to?(:show_and_edit_rates, @rate.project) &&  !(User.current.admin?)
            url = url_for(:controller => 'rates', :action => 'index', :id => @rate.user_id, user_id: @rate.user_id, project_id: @rate.project_id )
            redirect_to url
          else
            redirect_back_or_default(rates_url(user_id: @rate.user_id))
          end
        end
        format.xml  { render xml: @rate, status: :created, location: @rate }
        format.js { render action: :create }
      else
        format.html { render action: 'new' }
        format.xml  { render xml: @rate.errors, status: :unprocessable_entity }
        format.js do
          flash.now[:error] = l(:rate_error_creating_new_rate)
          render action: :create_error
        end
      end
    end
  end

  # PUT /rates/1
  # PUT /rates/1.xml
  def update
    @rate = Rate.find(params[:id])

    respond_to do |format|
      # Locked rates will fail saving here.
      if @rate.update(rate_params)

        unless Rate.rate_locking_enabled?
        ids =  Rate.where(date_in_effect: rate_params[:date_in_effect], project_id: @rate.project_id, user_id: @rate.user_id).ids
        current_rate_id = @rate.id
        skip_lock_feature_and_recalculate_cost!(ids, current_rate_id)
        end

        flash[:notice] = l(:rate_updated_message)

        if User.current.allowed_to?(:show_and_edit_rates, @rate.project) &&  !(User.current.admin?)
          url = url_for(:controller => 'rates', :action => 'index', :id => @rate.user_id, user_id: @rate.user_id, project_id: @rate.project_id, format: "html" )
          format.html { redirect_to url}
          format.xml  { head :ok }
        else
          format.html { redirect_back_or_default(rates_url(user_id: @rate.user_id)) }
          format.xml  { head :ok }

        end

      else
        if @rate.locked?
          flash[:error] = l(:rate_locked_message)
          @rate.reload # Removes attribute changes
        end
        format.html { render action: 'edit' }
        format.xml  { render xml: @rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rates/1
  # DELETE /rates/1.xml
  def destroy
    @rate = Rate.find(params[:id])
    rate  = @rate
    @rate.destroy

    respond_to do |format|
      format.html do
        if @rate.locked?
          flash[:error] = 'Rate is locked and cannot be deleted'

          if User.current.allowed_to?(:show_and_edit_rates, rate.project) &&  !(User.current.admin?)
            url = url_for(:controller => 'rates', :action => 'index', :id => rate.user_id, user_id: rate.user_id, project_id: rate.project_id )
            redirect_to  url
          end

        else
          flash[:notice] = 'Rate was deleted.'
          if User.current.allowed_to?(:show_and_edit_rates, rate.project) &&  !(User.current.admin?)
            url = url_for(:controller => 'rates', :action => 'index', :id => rate.user_id, user_id: rate.user_id, project_id: rate.project_id )
            redirect_to  url
          else
            redirect_back_or_default rates_url(user_id: @rate.user_id)
          end
        end
      end
      format.xml { head :ok }
    end
  end

  private

  def rate_params
    params.require(:rate).permit :amount, :date_in_effect, :project_id, :user_id
  end

  def require_user_id
    @user = User.find(params[:user_id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      flash[:error] = l(:rate_error_user_not_found)
      format.html { redirect_to(home_url) }
      format.xml  { render xml: 'User not found', status: :not_found }
    end
  end

  def set_back_url
    @back_url = params[:back_url]
    @back_url
  end

  def skip_lock_feature_and_recalculate_cost!(ids, current_rate_id)

    time_entries = TimeEntry.where(rate_id: ids)
    time_entries.each do |e|
      e.rate_id = current_rate_id
      e.save
    end

    TimeEntry.find_each do |time_entry| # batch find
      begin
        time_entry.recalculate_cost!
      rescue Rate::InvalidParameterException => ex
        Rails.logger.error "Error saving #{time_entry.id}: #{ex.message}"
      end
    end
  end

  # Override defination from ApplicationController to make sure it follows a
  # whitelist
  def redirect_back_or_default(default)
    whitelist = %r{(rates|/users/edit)}

    back_url = CGI.unescape(params[:back_url].to_s)
    if back_url.present?
      begin
        uri = URI.parse(back_url)
        if uri.path && uri.path.match(whitelist)
          super
          return
        end
      rescue URI::InvalidURIError
        # redirect to default
        logger.debug('Invalid URI sent to redirect_back_or_default: ' + params[:back_url].inspect)
      end
    end
    redirect_to default
  end

  def set_project
    rate = Rate.find(params[:id])
    @project = rate.project
  end

  def require_admin_or_editable_role_permission
    return unless require_login

      project_id =  params["rate"]["project_id"] rescue params["project_id"]
       project_id = params["project_id"]  if project_id.nil?
      if project_id.present?
        @project =  Project.find(project_id)
      end

    if !User.current.admin? &&  !(User.current.allowed_to?(:show_and_edit_rates, @project))
      render_403
      return false
    end
    true
  end

end
