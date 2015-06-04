class AddManyToManyRelationToProducts < ActiveRecord::Migration
  def self.up
    create_table :spree_items_in_collections, id: false do |t|
      t.integer 'collection_id', null: false
      t.integer 'item_id', null: false
      t.integer 'count', null: false, default: 1
    end
  end

  def self.down
    drop_table :spree_items_in_collections
  end
end
