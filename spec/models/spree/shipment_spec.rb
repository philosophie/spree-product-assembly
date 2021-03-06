require 'spec_helper'

describe Spree::Shipment do
  context 'order has one product collection' do
    let(:order) { create(:order) }
    let(:bundle) { create(:variant) }
    let!(:items) { create_list(:variant, 2) }
    let!(:bundle_items) { bundle.product.items << items }

    let!(:line_item) { order.contents.add(bundle, 1) }
    let!(:shipment) { order.create_proposed_shipments.first }

    before { order.update_column :state, 'complete' }

    it 'shipment item cost equals line item amount' do
      expect(shipment.item_cost).to eq line_item.amount
    end
  end

  context 'manifests' do
    include_context 'product is ordered as individual and within a bundle'

    let(:shipments) { order.create_proposed_shipments }

    context 'default' do
      let(:expected_variants) do
        order.variants - [bundle_variant] + bundle.items
      end

      it 'separates variant purchased individually from the bundle one' do
        expect(shipments.count).to eql 1
        result = shipments.first.manifest.map(&:variant).sort
        result.should == expected_variants.sort
      end
    end

    context 'line items manifest' do
      let(:expected_variants) { order.variants }

      it 'groups units by line_item only' do
        expect(shipments.count).to eql 1
        result = shipments.first.line_item_manifest.map(&:variant).sort
        result.should == expected_variants.sort
      end
    end

    context 'units are not associated with a line item' do
      let(:order) { create(:shipped_order) }
      let(:shipment) { order.shipments.first }

      it "searches for line item if inventory unit doesn't have one" do
        shipment.manifest.last.line_item.should_not be_blank
      end
    end
  end

  context 'set up new inventory units' do
    let(:line_item) { create(:line_item) }
    let(:variant) { line_item.variant }
    let(:order) { line_item.order }
    let(:shipment) { create(:shipment) }

    it 'assigns variant, order and line_item' do
      unit = shipment.set_up_inventory('on_hand', variant, order, line_item)

      expect(unit.line_item).to eq line_item
      expect(unit.variant).to eq variant
      expect(unit.order).to eq order
      expect(unit.state).to eq 'on_hand'
    end
  end

  context 'unit states for variant sold as item in a ' \
    'collection and separately' do
    let(:collection_line_item) { create(:line_item) }
    let(:shirt) { create(:variant) }

    let(:collection_shirts) do
      create_list(
        :inventory_unit,
        5,
        variant: shirt,
        line_item: collection_line_item,
        state: :on_hand
      )
    end

    let(:standalone_line_item) { create(:line_item, variant: shirt) }

    let(:standalone_shirts) do
      create_list(
        :inventory_unit,
        2,
        variant: shirt,
        line_item: standalone_line_item,
        state: :on_hand
      )
    end

    let(:shipment) { create(:shipment) }

    before do
      shipment.inventory_units << collection_shirts
      shipment.inventory_units << standalone_shirts
    end

    it 'set states numbers properly for all items' do
      shipment.manifest.each do |item|
        if item.line_item.id == standalone_line_item.id
          expect(item.states['on_hand']).to eq standalone_shirts.count
        else
          expect(item.states['on_hand']).to eq collection_shirts.count
        end
      end
    end
  end
end
