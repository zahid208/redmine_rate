require 'redmine'

module RedmineRate
  def self.settings
    ActionController::Parameters.new(Setting[:plugin_redmine_rate].instance_values["parameters"]) rescue  ActionController::Parameters.new( Setting[:plugin_redmine_rate])
  end

  def self.setting?(value)
    return true if settings[value].to_i == 1
    false
  end
end

Rails.application.config.to_prepare do
  Rails.application.paths['app/overrides'] ||= []
  rate_overwrite_dir = "#{Redmine::Plugin.directory}/redmine_rate/app/overrides".freeze
  unless Rails.application.paths['app/overrides'].include?(rate_overwrite_dir)
    Rails.application.paths['app/overrides'] << rate_overwrite_dir
  end
end
