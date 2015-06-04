module Spree
  LineItem.class_eval do
    scope :collections, -> { joins(product: :items).uniq }

    def any_units_shipped?
      inventory_units.any?(&:shipped?)
    end

    # The collection items that apply to this particular LineItem.
    # Usually `product#items`, but provided as a hook if you want to
    # override and customize the items for a specific LineItem.
    def items
      product.items
    end

    # The number of the specified variant that make up this LineItem.
    # By default, calls `product#count_of`, but provided as a hook if you want
    # to override and customize the items available for a specific LineItem.
    # Note that if you only customize whether a variant is included in the
    # LineItem, and don't customize the quantity of that part per LineItem,
    # you shouldn't need to override this method.
    def count_of(variant)
      product.count_of(variant)
    end

    def quantity_by_variant
      if product.collection?
        {}.tap do |hash|
          product.items_in_collections.each do |iic|
            hash[iic.item] = iic.count * quantity
          end
        end
      else
        { variant => quantity }
      end
    end

    private

    def update_inventory
      do_update if should_update?
    end

    def do_update
      if product.collection?
        OrderInventoryCollection.new(self).verify(target_shipment)
      else
        OrderInventory.new(order, self).verify(target_shipment)
      end
    end

    def should_update?
      (changed? || target_shipment.present?) &&
        order.has_checkout_step?('delivery')
    end
  end
end
