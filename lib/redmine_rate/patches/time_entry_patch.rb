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
          before_save :set_billable
          after_initialize :initialize_billable

          safe_attributes 'billable'
        end
      end

      module ClassMethods
        # Updated the cached cost of all TimeEntries for user and project
        def update_cost_cache(user, project = nil)
          c = { user_id: user }
          c[:project_id] = project unless project.nil?
          TimeEntry.where(c).each(&:recalculate_cost!)
        end
      end

      module InstanceMethods
        def initialize_billable
          return unless new_record?
          self.billable = if RedmineRate.settings[:billable_default].to_i == 1
                            true
                          else
                            false
                          end
        end

        def set_billable
          return true if User.current.allowed_to?(:activate_billable, project)
          self.billable = if RedmineRate.settings[:billable_default].to_i == 1
                            true
                          else
                            false
                          end
          true
        end

        # Returns the current cost of the TimeEntry based on it's
        # billable rate and hours.
        def cost
          cost = read_attribute(:cost)
          return cost if cost
          write_attribute(:cost, calculate_cost)
        end

        # Updates the cost attribute with the recalculated cost value.
        def recalculate_cost!
          cost = calculate_cost
          update_attribute(:cost, cost)
          cost
        end

        # Writes the cost attribute to the model instance with the
        # recalculated cost value.
        def recalculate_cost
          write_attribute(:cost, calculate_cost)
        end

        private

        # Returns the cost for this time entry depending on rates set
        # and whether this time entry is billable or not.
        def calculate_cost
          return 0.0 unless billable
          amount = if rate.nil?
                     Rate.amount_for(user, project, spent_on.to_s)
                   else
                     rate.amount
                   end
          return 0.0 unless amount
          amount.to_f * hours.to_f
        end
      end
    end
  end
end

unless TimeEntry.included_modules.include?(RedmineRate::Patches::TimeEntryPatch)
  TimeEntry.send(:include, RedmineRate::Patches::TimeEntryPatch)
end
