require 'redmine'
# require 'redmine_rate'

# require_relative '/lib/redmine_rate/hooks.rb'
require_relative 'lib/redmine_rate/hooks'



Redmine::Plugin.register :redmine_rate do
  name 'Rate'
  author 'AlphaNodes GmbH | Eric Davis | Upgraded by Zahid Zaidi(zahidhanif208@gmail.com) '
  url 'https://www.fiverr.com/zahidhanif'
  description 'The Rate plugin provides an API that can be used to find the rate for a Member of a Project at a specific date.
               It also stores historical rate data so calculations will remain correct in the future.
(Upgraded by Zahid Zaidi )'
  version '1.1.6'

  requires_redmine version_or_higher: '3.3.0'

  default_settings = {
    last_caching_run: nil,
    billable_default: 1,
    currency: 'EUR',
    enable_rate_lock: 1
  }

  project_module :time_tracking do
    permission :activate_billable, {}
    permission :show_and_edit_rates, {}
  end

  settings(default: default_settings, partial: 'settings/rate/rate')
end

#Ignore Files For zeitwerk Autoload
# rails zeitwerk:check Passed!
if Rails.configuration.respond_to?(:autoloader) && Rails.configuration.autoloader == :zeitwerk
  Rails.autoloaders.each { |loader| loader.ignore(File.dirname(__FILE__) + '/lib') }
  Rails.autoloaders.each { |loader| loader.ignore(File.dirname(__FILE__) + '/app/overrides') }
end
require File.dirname(__FILE__) + '/lib/redmine_rate'
