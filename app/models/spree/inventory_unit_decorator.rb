module Spree
  InventoryUnit.class_eval do
    def percentage_of_line_item
      product = line_item.product
      if product.collection?
        variant.price / line_item_total_value
      else
        1 / BigDecimal.new(line_item.quantity)
      end
    end

    private

    def line_item_total_value
      line_item.quantity_by_variant.map do |item, quantity|
        item.price * quantity
      end.sum
    end
  end
end
