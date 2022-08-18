
module RedmineRate
    module SettingPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          after_update :recalculate_cost_for_all_entries
        end
      end

      module ClassMethods
        # Updated the cached cost of all TimeEntries for user and project
      end

      module InstanceMethods

        def recalculate_cost_for_all_entries
          TimeEntry.find_each do |time_entry| # batch find
            begin
              time_entry.recalculate_cost!
            rescue Rate::InvalidParameterException => ex
              Rails.logger.error "Error saving #{time_entry.id}: #{ex.message}"
            end
          end
        end

        end
      end
    end


unless Setting.included_modules.include?(RedmineRate::SettingPatch)
  Setting.send(:include, RedmineRate::SettingPatch)
end
