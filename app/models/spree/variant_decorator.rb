Spree::Variant.class_eval do
  has_and_belongs_to_many :collections,
                          class_name: 'Spree::Product',
                          join_table: 'spree_items_in_collections',
                          foreign_key: 'item_id',
                          association_foreign_key: 'collection_id'

  def collections_for(products)
    collections.where(id: products)
  end

  def item?
    collections.exists?
  end
end
