class AddColumnsOnSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_reference :subscriptions, :next_chapter, foreign_key: { to_table: :chapters }
    add_reference :subscriptions, :last_chapter, foreign_key: { to_table: :chapters }
    add_column :subscriptions, :delivery_hour, :integer, default: 8, null: false
    add_column :subscriptions, :next_deliver_at, :date
  end
end
