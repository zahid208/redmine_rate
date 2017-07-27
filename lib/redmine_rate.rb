module RedmineRate
  def self.settings
    ActionController::Parameters.new(Setting[:plugin_redmine_rate])
  end
end

Rails.configuration.to_prepare do
  # Patches
  require 'redmine_rate/patches/issue_patch'
  require 'redmine_rate/patches/issue_query_patch'
  require 'redmine_rate/patches/time_entry_patch'
  require 'redmine_rate/patches/time_entry_query_patch'
  require 'redmine_rate/patches/time_report_patch'
  require 'redmine_rate/patches/users_helper_patch'
  require 'redmine_rate/patches/queries_helper_patch'

  # Global helpers
  require_dependency 'redmine_rate/helpers'

  # Hooks
  require_dependency 'redmine_rate/hooks'

  # include deface overwrites
  Rails.application.paths['app/overrides'] ||= []
  rate_overwrite_dir = "#{Redmine::Plugin.directory}/redmine_rate/app/overrides".freeze
  unless Rails.application.paths['app/overrides'].include?(rate_overwrite_dir)
    Rails.application.paths['app/overrides'] << rate_overwrite_dir
  end
end
