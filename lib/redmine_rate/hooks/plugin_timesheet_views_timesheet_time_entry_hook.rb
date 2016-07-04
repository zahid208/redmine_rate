module RedmineRate
  module Hooks
    class PluginTimesheetViewsTimesheetTimeEntryHook < Redmine::Hook::ViewListener
      include TimesheetHookHelper

      def plugin_timesheet_views_timesheet_time_entry(context = {})
        cost = cost_item(context[:time_entry])
        if cost
          td_cell(show_number_with_currency(cost))
        else
          td_cell('&nbsp;')
        end
      end
    end
  end
end
