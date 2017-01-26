require_dependency 'redmine/helpers/time_report'

module RedmineRate
  module Patches
    module TimeReportPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          # alias_method_chain :load_available_criteria, :cost

          def load_available_criteria2
            return if @with_rate_criteria
            @with_rate_criteria ||= true
            @available_criteria['billable'] = {
              sql: "#{TimeEntry.table_name}.billable",
              format: 'bool',
              label: :billable
            }
            @available_criteria
          end
        end
      end

      module InstanceMethods
        def load_available_criteria_with_cost
          @available_criteria = load_available_criteria_without_cost
          @available_criteria['billable'] = {
            sql: "#{TimeEntry.table_name}.billable",
            format: 'bool',
            label: :billable
          }
          @available_criteria
        end
      end
    end
  end
end

unless Redmine::Helpers::TimeReport.included_modules.include?(RedmineRate::Patches::TimeReportPatch)
  Redmine::Helpers::TimeReport.send(:include, RedmineRate::Patches::TimeReportPatch)
end
