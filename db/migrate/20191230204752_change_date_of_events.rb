class ChangeDateOfEvents < ActiveRecord::Migration[6.0]
  def change
    remove_column :events, :date
    add_column :events, :date, :datetime
  end
end
