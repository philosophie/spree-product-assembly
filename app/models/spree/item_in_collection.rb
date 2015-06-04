module Spree
  class ItemInCollection < ActiveRecord::Base
    belongs_to :collection,
               class_name: 'Spree::Product',
               foreign_key: 'collection_id', touch: true

    belongs_to :item,
               class_name: 'Spree::Variant',
               foreign_key: 'item_id'

    def self.table_name
      'spree_items_in_collections'
    end

    def self.get(collection_id, item_id)
      find_or_initialize_by(collection_id: collection_id, item_id: item_id)
    end
  end
end
