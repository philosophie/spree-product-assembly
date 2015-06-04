Spree::Product.class_eval do
  has_and_belongs_to_many :items,
                          class_name: 'Spree::Variant',
                          join_table: 'spree_items_in_collections',
                          foreign_key: 'collection_id',
                          association_foreign_key: 'item_id'

  has_many :items_in_collections,
           class_name: 'Spree::ItemInCollection',
           foreign_key: 'collection_id'

  scope :individual_saled, -> { where(individual_sale: true) }

  scope :search_can_be_item, ->(query) {
    not_deleted.available.joins(:master)
      .where(
        arel_table['name']
          .matches("%#{query}%")
          .or(Spree::Variant.arel_table['sku'].matches("%#{query}%"))
      )
      .where(can_be_item: true)
      .limit(30)
  }

  validate :collection_cannot_be_item, if: :collection?

  def add_item(variant, count = 1)
    set_item_count(variant, count_of(variant) + count)
  end

  def remove_item(variant)
    set_item_count(variant, 0)
  end

  def set_item_count(variant, count)
    in_collection = item_in_collection(variant)
    if count > 0
      in_collection.count = count
      in_collection.save
    else
      in_collection.destroy
    end
    reload
  end

  def collection?
    items.present?
  end

  def count_of(variant)
    in_collection = item_in_collection(variant)
    # This checks persisted because the default count is 1
    in_collection.persisted? ? in_collection.count : 0
  end

  def collection_cannot_be_item
    errors.add(:can_be_item, Spree.t(:collection_cannot_be_item)) if can_be_item
  end

  private

  def item_in_collection(variant)
    Spree::ItemInCollection.get(id, variant.id)
  end
end
