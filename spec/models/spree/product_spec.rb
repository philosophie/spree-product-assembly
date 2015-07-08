require 'spec_helper'

describe Spree::Product do
  describe 'Spree::Product Assembly' do
    describe 'general properties' do
      let!(:product) { create(:product, name: 'Foo Bar') }
      let!(:master_variant) { product.master }
      let!(:item1) { create(:product, can_be_item: true) }
      let!(:item2) { create(:product, can_be_item: true) }

      before(:each) do
        product.add_item(item1.master, 1)
        product.add_item(item2.master, 4)
      end

      it 'is a collection' do
        product.should be_collection
      end

      it 'cannot be item' do
        product.should be_collection
        product.can_be_item = true
        product.valid?
        product.errors[:can_be_item]
          .should == ["collection can't be in other collections"]
      end

      it 'changing item qty changes count on_hand' do
        product.set_item_count(item2.master, 2)
        product.count_of(item2.master).should == 2
      end
    end

    describe 'scopes' do
      describe '.collection' do
        it 'returns Products which are collections' do
          collection1 =
            create(:product, can_be_item: false, individual_sale: true)
          item1 = create(:product, can_be_item: true, individual_sale: false)
          collection1.add_item(item1.master, 1)

          collection2 =
            create(:product, can_be_item: false, individual_sale: true)
          item2 = create(:product, can_be_item: true, individual_sale: false)
          collection2.add_item(item2.master, 1)

          expected_collections = [collection1, collection2]

          expect(described_class.collections)
            .to match_array(expected_collections)
        end
      end
    end
  end
end
