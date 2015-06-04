module Spree
  # This class has basically the same functionality of Spree core OrderInventory
  # except that it takes account of bundle items and properly creates and
  # removes inventory unit for each item of a bundle
  class OrderInventoryCollection < OrderInventory
    attr_reader :product

    def initialize(line_item)
      @order = line_item.order
      @line_item = line_item
      @product = line_item.product
    end

    def verify(shipment = nil)
      do_verify(shipment) if order.completed? || shipment.present?
    end

    private

    def do_verify(shipment)
      line_item.quantity_by_variant.each do |item, total_items|
        existing_items = line_item.inventory_units.where(variant: item).count

        # Set the variant so it can be reconciled via OrderInventory logic
        self.variant = item

        reconcile_quantity(shipment, existing_items, total_items)
      end
    end

    def reconcile_quantity(shipment, existing_items, total_items)
      if existing_items < total_items
        shipment ||= determine_target_shipment
        add_to_shipment(shipment, total_items - existing_items)
      elsif existing_items > total_items
        remove_items_from_shipment(shipment, existing_items - total_items)
      end
    end

    def remove_items_from_shipment(shipment, quantity)
      if shipment.present?
        remove_from_shipment(shipment, quantity)
      else
        order.shipments.each do |order_shipment|
          break if quantity == 0
          quantity -= remove_from_shipment(order_shipment, quantity)
        end
      end
    end
  end
end
