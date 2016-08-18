class RateCachesController < ApplicationController
  layout 'admin'

  before_action :require_admin

  def update
    if params[:cache].present?
      if params[:cache] =~ /missing/
        Rate.update_all_time_entries_with_missing_cost(force: true)
        flash[:notice] = l(:text_caches_loaded_successfully)
      elsif params[:cache] =~ /reload/
        Rate.update_all_time_entries_to_refresh_cache(force: true)
        flash[:notice] = l(:text_caches_loaded_successfully)
      end
    end
    redirect_to action: 'plugin', id: 'redmine_rate', controller: 'settings', tab: 'caches'
  end
end
