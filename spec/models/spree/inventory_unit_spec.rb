require 'spec_helper'

describe Spree::InventoryUnit do
  let!(:order) { create(:order_with_line_items) }
  let(:line_item) { order.line_items.first }
  let(:product) { line_item.product }

  subject do
    Spree::InventoryUnit.create(
      line_item: line_item,
      variant: line_item.variant,
      order: order
    )
  end

  context 'if the unit is not an item of an collection' do
    it 'it will return the percentage of a line item' do
      expect(subject.percentage_of_line_item).to eql(BigDecimal.new(1))
    end
  end

  context 'if an item in a collection' do
    let(:items) { create_list(:variant, 2) }

    before do
      product.items << items
      order.create_proposed_shipments
      order.finalize!
    end

    it 'it will return the percentage of a line item' do
      subject.line_item = line_item
      expect(subject.percentage_of_line_item).to eql(BigDecimal.new(0.5, 2))
    end
  end
end
