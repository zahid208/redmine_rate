class AddRateIdToTimeEntries < ActiveRecord::Migration
  def change
    add_reference :time_entries, :rate, index: true
  end
end
