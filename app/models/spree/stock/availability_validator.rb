module Spree
  module Stock
    # Overridden from spree core to make it also check for
    # collection items stock
    class AvailabilityValidator < ActiveModel::Validator
      def validate(line_item)
        line_item.quantity_by_variant.each do |variant, variant_quantity|
          do_validate(line_item, variant, variant_quantity)
        end
      end

      private

      def do_validate(line_item, variant, variant_quantity)
        inventory_units =
          line_item.inventory_units.where(variant: variant).count
        quantity = variant_quantity - inventory_units

        return if quantity <= 0

        quantifier = Stock::Quantifier.new(variant)

        quantity_error(line_item, variant) unless quantifier.can_supply?(quantity)
      end

      def quantity_error(line_item, variant)
        line_item.errors[:quantity] << Spree.t(
          :selected_quantity_not_available,
          item: error_display_name(variant).inspect
        )
      end

      def error_display_name(variant)
        display_name = %(#{variant.name})
        display_name +=
          %( (#{variant.options_text})) unless variant.options_text.blank?
        display_name
      end
    end
  end
end
