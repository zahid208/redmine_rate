class AddRateIdToTimeEntries < ActiveRecord::Migration
  def change
    add_column :time_entries, :rate_id, :integer, index: true
  end
end
