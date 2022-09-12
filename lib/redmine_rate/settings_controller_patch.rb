module RedmineRate
  module SettingsControllerPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method :rake_task_without_plugin, :plugin
        alias_method :plugin, :rake_task_with_plugin
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def rake_task_with_plugin
        rake_task_without_plugin  unless request.post?
        rake_task_without_plugin unless params[:id] == "redmine_rate"

        @plugin = Redmine::Plugin.find(params[:id])
        unless @plugin.configurable?
          render_404
          return
        end

        if request.post?
          setting = params[:settings] ? params[:settings].permit!.to_h : {}
          Setting.send "plugin_#{@plugin.id}=", setting
          flash[:notice] = l(:notice_successful_update)

          Rails.application.load_tasks
          Rake::Task['rate_plugin:cache:refresh_cost_cache'].invoke

          redirect_to plugin_settings_path(@plugin)
        else
          rake_task_without_plugin
        end
      end

    end
  end
end

unless SettingsController.included_modules.include?(RedmineRate::SettingsControllerPatch)
  SettingsController.send(:include, RedmineRate::SettingsControllerPatch)
end
