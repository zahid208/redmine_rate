class AddBillableToTimeEntries < ActiveRecord::Migration
  def change
    add_column :time_entries, :billable, :boolean, default: true, null: false
    add_index :time_entries, :billable
  end
end
