require 'spec_helper'

module Spree
  describe ItemInCollection do
    let(:product) { create(:product) }
    let(:variant) { create(:variant) }

    before do
      product.items.push variant
    end

    context 'get' do
      it 'brings item by product and variant id' do
        subject.class.get(product.id, variant.id).item.should == variant
      end
    end
  end
end
