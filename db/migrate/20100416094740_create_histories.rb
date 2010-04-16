class CreateHistories < ActiveRecord::Migration
  def self.up
    create_table :histories do |t|
      t.column :date, :date
      t.column :uris_count, :integer

      t.timestamps
    end
  end

  def self.down
    drop_table :histories
  end
end
