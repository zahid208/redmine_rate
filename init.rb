require 'redmine_rate'

Redmine::Plugin.register :redmine_rate do
  name 'Rate'
  author 'AlphaNodes GmbH, Eric Davis'
  url 'https://github.com/alexandermeindl/redmine_rate'
  description 'The Rate plugin provides an API that can be used to find the rate for a Member of a Project at a specific date.
               It also stores historical rate data so calculations will remain correct in the future.'
  version '0.2.2-dev'

  requires_redmine version_or_higher: '3.3.0'

  # These settings are set automatically when caching
  settings(default: {
             'last_caching_run' => nil
           })

  permission :view_rate, {}

  menu :admin_menu, :rate_caches, { controller: 'rate_caches', action: 'index' }, caption: :text_rate_caches_panel
end
