require 'spec_helper'

module Spree
  module Wombat
    describe AssemblyShipmentSerializer do
      let(:order) { Order.create }
      before { order.update_column :state, 'complete' }

      context 'with bundle line item' do
        let(:bundle) { create(:variant) }
        let!(:items) { (1..2).map { create(:variant) } }
        let!(:bundle_items) { bundle.product.items << items }
        let!(:line_item) { order.contents.add(bundle, 1) }
        let!(:shipment) { order.create_proposed_shipments.first }
        let(:serialized_shipment) do
          JSON.parse(
            AssemblyShipmentSerializer.new(shipment, root: false).to_json
          )
        end

        it 'adds a bundled_items object' do
          expect(serialized_shipment['items'].first['bundled_items'])
            .to_not be_nil
        end
      end

      context 'with regular line_item' do
        let!(:line_item) { order.contents.add(create(:variant), 1) }
        let!(:shipment) { order.create_proposed_shipments.first }
        let(:serialized_shipment) do
          JSON.parse(
            AssemblyShipmentSerializer.new(shipment, root: false).to_json
          )
        end

        it 'will not add the bundled_items object' do
          expect(serialized_shipment['items'].first['bundled_items']).to be_nil
        end
      end
    end
  end
end
