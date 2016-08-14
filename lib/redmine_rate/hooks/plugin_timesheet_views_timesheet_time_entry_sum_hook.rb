module RedmineRate
  module Hooks
    class PluginTimesheetViewsTimesheetTimeEntrySumHook < Redmine::Hook::ViewListener
      include TimesheetHookHelper

      def plugin_timesheet_views_timesheet_time_entry_sum(context = {})
        time_entries = context[:time_entries]
        costs = time_entries.collect { |time_entry| cost_item(time_entry) }.compact.sum
        if costs >= 0
          td_cell(show_number_with_currency(costs))
        else
          td_cell('&nbsp;')
        end
      end
    end
  end
end
