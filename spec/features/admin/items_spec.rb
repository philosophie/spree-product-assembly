require 'spec_helper'

describe 'Parts', type: :feature, js: true do
  stub_authorization!

  let!(:tshirt) { create(:product, name: 'T-Shirt') }
  let!(:mug) { create(:product, name: 'Mug') }

  before do
    visit spree.admin_product_path(mug)
    check 'product_can_be_item'
    click_on 'Update'
  end

  it 'add and remove item' do
    visit spree.admin_product_path(tshirt)
    click_on 'Items'
    fill_in 'searchtext', with: mug.name
    click_on 'Search'

    within('#search_hits') do
      click_on 'Select'
    end

    within('#product_items') do
      page.should have_content(mug.sku)
    end
  end
end
