require 'spec_helper'

describe Spree::OrderInventoryCollection do
  let(:order) { create(:order_with_line_items) }
  let(:line_item) { order.line_items.first }
  let(:bundle) { line_item.product }
  let(:items) { create_list(:variant, 3) }

  before do
    bundle.items << [items]
    bundle.set_item_count(items.first, 3)

    line_item.update_attributes!(quantity: 3)
    order.reload.create_proposed_shipments
    order.finalize!
  end

  subject { Spree::OrderInventoryCollection.new(line_item) }

  context 'inventory units count' do
    it 'calculates the proper value for the bundle' do
      expected_units_count =
        line_item.quantity * bundle.items_in_collections.to_a.sum(&:count)
      expect(subject.inventory_units.count).to eql(expected_units_count)
    end
  end

  context 'verify line item units' do
    let!(:original_units_count) { subject.inventory_units.count }

    context 'quantity increases' do
      before { subject.line_item.quantity += 1 }

      it 'inserts new inventory units for every bundle item' do
        expected_units_count =
          original_units_count + bundle.items_in_collections.to_a.sum(&:count)
        subject.verify
        result =
          Spree::OrderInventoryCollection.new(line_item.reload)
          .inventory_units.count
        expect(result).to eql(expected_units_count)
      end
    end

    context 'quantity decreases' do
      before { subject.line_item.quantity -= 1 }

      it 'remove inventory units for every bundle item' do
        expected_units_count =
          original_units_count - bundle.items_in_collections.to_a.sum(&:count)
        subject.verify

        # needs to reload so that inventory units are fetched from updates
        # order.shipments
        updated_units_count =
          Spree::OrderInventoryCollection.new(line_item.reload)
          .inventory_units.count
        expect(updated_units_count).to eql(expected_units_count)
      end
    end
  end
end
