class CreateMentionCorrelations < ActiveRecord::Migration[7.0]
  def change
    create_table :mention_correlations do |t|
      t.integer :mention_id
      t.integer :mentioned_id

      t.timestamps
    end
    add_index :mention_correlations, :mention_id
    add_index :mention_correlations, :mentioned_id
    add_index :mention_correlations, [:mention_id, :mentioned_id], unique: true
  end
end
