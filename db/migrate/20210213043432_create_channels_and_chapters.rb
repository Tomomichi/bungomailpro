class CreateChannelsAndChapters < ActiveRecord::Migration[6.0]
  def change
    create_table :channels, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :send_to
      t.string :title
      t.timestamps
    end

    create_table :book_assignments, id: :uuid do |t|
      t.references :channel, type: :uuid, null: false, foreign_key: true
      t.integer :book_id, null: false
      t.string :book_type, null: false
      t.integer :count, null: false
      t.datetime :start_at, null: false
      t.timestamps
    end
    add_index :book_assignments, [:book_id, :book_type]

    create_table :chapters, id: :uuid do |t|
      t.references :book_assignment, type: :uuid, null: false, foreign_key: true
      t.references :delayed_job, type: :uuid, null: true, foreign_key: true
      t.string :title, null: false
      t.text :content, null: false
      t.datetime :send_at, null: false
      t.timestamps
    end
  end
end
