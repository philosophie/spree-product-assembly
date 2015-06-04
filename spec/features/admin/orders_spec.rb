require 'spec_helper'

# Current requirements disallow editing from shipment page
describe 'Orders', type: :feature, pending: true do
  let!(:admin) { create(:admin_user) }
  let(:order) { create(:order_with_line_items) }
  let(:line_item) { order.line_items.first }
  let(:bundle) { line_item.product }
  let(:items) { create_list(:variant, 3) }

  before do
    allow_any_instance_of(Spree::Admin::OrdersController)
      .to receive(:spree_current_user).and_return(admin)

    bundle.items << [items]
    line_item.update_attributes!(quantity: 3)
    order.reload.create_proposed_shipments
    order.finalize!
  end

  it 'allows admin to edit product bundle' do
    visit spree.edit_admin_order_path(order)

    within('table.product-bundles') do
      find('.edit-line-item').click
      fill_in 'quantity', with: '2'
      find('.save-line-item').click

      # avoid odd "cannot rollback - no transaction is active:
      # rollback transaction"
      sleep(1)
    end
  end
end
