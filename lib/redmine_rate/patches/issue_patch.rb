require_dependency 'time_entry'

module RedmineRate
  module Patches
    module IssuePatch
      def self.included(base)
        base.send(:include, InstanceMethods)
      end

      module InstanceMethods
        # Returns the number of hours spent on this issue
        def cost
          @cost ||= time_entries.sum(:cost) || 0.0
        end

        # Returns the total number of hours spent on this issue and its descendants
        def total_cost
          @total_cost ||=
            if leaf?
              cost
            else
              self_and_descendants.joins(:time_entries).sum("#{TimeEntry.table_name}.cost").to_f || 0.0
            end
        end
      end
    end
  end
end

unless Issue.included_modules.include?(RedmineRate::Patches::IssuePatch)
  Issue.send(:include, RedmineRate::Patches::IssuePatch)
end
