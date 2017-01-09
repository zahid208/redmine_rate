require_dependency 'time_entry'

module RedmineRate
  module Patches
    module TimeEntryPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          belongs_to :rate
          before_save :recalculate_cost
        end
      end

      module ClassMethods
        # Updated the cached cost of all TimeEntries for user and project
        def update_cost_cache(user, project = nil)
          c = {}
          c[:user_id] = user
          c[:project_id] = project unless project.nil?

          TimeEntry.where(c).each do |time_entry|
            time_entry.save_cached_cost
          end
        end
      end

      module InstanceMethods
        # Returns the current cost of the TimeEntry based on it's rate and hours
        #
        # Is a read-through cache method
        def cost(options = {})
          store_to_db = options[:store] || false

          unless read_attribute(:cost)
            amount = if rate.nil?
                       Rate.amount_for(user, project, spent_on.to_s)
                     else
                       rate.amount
                     end

            if amount.nil?
              write_attribute(:cost, 0.0)
            elsif store_to_db
              # Write the cost to the database for caching
              update_attribute(:cost, amount.to_f * hours.to_f)
            else
              # Cache to object only
              write_attribute(:cost, amount.to_f * hours.to_f)
            end
          end

          read_attribute(:cost)
        end

        def clear_cost_cache
          write_attribute(:cost, nil)
        end

        def save_cached_cost
          clear_cost_cache
          update_attribute(:cost, cost)
        end

        def recalculate_cost
          clear_cost_cache
          cost(store: false)
          true # for callback
        end
      end
    end
  end
end

unless TimeEntry.included_modules.include?(RedmineRate::Patches::TimeEntryPatch)
  TimeEntry.send(:include, RedmineRate::Patches::TimeEntryPatch)
end
