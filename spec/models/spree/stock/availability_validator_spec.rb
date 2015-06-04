require 'spec_helper'

module Spree
  module Stock
    describe AvailabilityValidator, type: :model do
      context 'line item has no items' do
        let!(:line_item) { create(:line_item, quantity: 5) }
        let!(:product) { line_item.product }

        subject { described_class.new }

        it 'should be valid when supply is sufficient' do
          Stock::Quantifier.any_instance.stub(can_supply?: true)
          expect(line_item).not_to receive(:errors)
          subject.validate(line_item)
        end

        it 'should be invalid when supply is insufficent' do
          Stock::Quantifier.any_instance.stub(can_supply?: false)
          expect(line_item.errors)
            .to receive(:[]).exactly(1).times.with(:quantity).and_return([])
          subject.validate(line_item)
        end

        it 'should consider existing inventory_units sufficient' do
          Stock::Quantifier.stub(can_supply?: false)
          line_item.inventory_units.stub(where: [double] * 5)
          expect(line_item).not_to receive(:errors)
          subject.validate(line_item)
        end
      end

      context 'line item has items' do
        let!(:order) { create(:order_with_line_items) }
        let(:line_item) { order.line_items.first }
        let(:product) { line_item.product }
        let(:variant) { line_item.variant }
        let(:items) { create_list(:variant, 2) }
        before { product.items << items }

        subject { described_class.new }

        it 'should be valid when supply of all items is sufficient' do
          Stock::Quantifier.any_instance.stub(can_supply?: true)
          expect(line_item).not_to receive(:errors)
          subject.validate(line_item)
        end

        it 'should be invalid when supplies of all items are insufficent' do
          Stock::Quantifier.any_instance.stub(can_supply?: false)
          expect(line_item.errors).to(
            receive(:[])
            .exactly(line_item.items.size).times
            .with(:quantity)
            .and_return([])
          )
          subject.validate(line_item)
        end

        it 'should be invalid when supply of 1 item is insufficient' do
          Stock::Quantifier.any_instance.stub(can_supply?: false)
          inventory_units = [double(variant: line_item.items.first)] * 5
          line_item.items.first.stub(inventory_units: inventory_units)
          expect(line_item.inventory_units)
            .to receive(:where).and_return(inventory_units, [])
          expect(line_item.errors)
            .to receive(:[]).exactly(1).times.with(:quantity).and_return([])
          subject.validate(line_item)
        end

        it 'should be valid when supply of each item is sufficient' do
          line_item.items.each do |item|
            item.stub(inventory_units: [double(variant: item)] * 5)
          end
          expect(line_item).not_to receive(:errors)
          subject.validate(line_item)
        end
      end
    end
  end
end
