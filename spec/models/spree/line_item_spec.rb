require 'spec_helper'

module Spree
  describe LineItem do
    let!(:order) { create(:order_with_line_items) }
    let(:line_item) { order.line_items.first }
    let(:product) { line_item.product }
    let(:variant) { line_item.variant }
    let(:inventory) { double('order_inventory') }

    context 'bundle items stock' do
      let(:items) { create_list(:variant, 2) }

      before { product.items << items }

      context 'one of them not in stock' do
        before do
          item = product.items.first
          item.stock_items.update_all backorderable: false

          expect(item).not_to be_in_stock
        end

        it "doesn't save line item quantity" do
          expect { order.contents.add(variant, 10) }
            .to raise_error ActiveRecord::RecordInvalid
        end
      end

      context 'in stock' do
        before do
          items.each do |item|
            item.stock_items.first.set_count_on_hand(10)
          end
          expect(items[0]).to be_in_stock
          expect(items[1]).to be_in_stock
        end

        it 'saves line item quantity' do
          line_item = order.contents.add(variant, 10)
          expect(line_item).to be_valid
        end
      end
    end

    context 'updates bundle product line item' do
      let(:items) { (1..2).map { create(:variant) } }

      before do
        product.items << items
        order.create_proposed_shipments
        order.finalize!
      end

      it 'verifies inventory units via OrderInventoryCollection' do
        OrderInventoryCollection.should_receive(:new)
          .with(line_item).and_return(inventory)
        inventory.should_receive(:verify).with(line_item.target_shipment)
        line_item.quantity = 2
        line_item.save
      end
    end

    context 'updates regular line item' do
      it 'verifies inventory units via OrderInventory' do
        OrderInventory.should_receive(:new)
          .with(line_item.order, line_item).and_return(inventory)
        inventory.should_receive(:verify).with(line_item.target_shipment)
        line_item.quantity = 2
        line_item.save
      end
    end
  end
end
