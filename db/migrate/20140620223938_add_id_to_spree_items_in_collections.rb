class AddIdToSpreeItemsInCollections < ActiveRecord::Migration
  def up
    add_column :spree_items_in_collections, :id, :primary_key
  end

  def down
    add_column :spree_items_in_collections, :id
  end
end
