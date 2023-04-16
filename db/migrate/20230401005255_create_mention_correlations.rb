class CreateMentionCorrelations < ActiveRecord::Migration[7.0]
  def change
    create_table :mention_correlations do |t|
      t.references :mention, null: false, foreign_key: { to_table: :reports }
      t.references :mentioned, null: false, foreign_key: { to_table: :reports }

      t.timestamps
    end
    add_index :mention_correlations, [:mention_id, :mentioned_id], unique: true
  end
end
