module RedmineRate
  module Hooks
    class PluginTimesheetViewsTimesheetGroupHeaderHook < Redmine::Hook::ViewListener
      def plugin_timesheet_views_timesheet_group_header(_context = {})
        content_tag(:th, l(:label_rate_cost), width: '8%')
      end
    end
  end
end
