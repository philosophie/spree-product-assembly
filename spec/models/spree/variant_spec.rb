require 'spec_helper'

describe Spree::Variant do
  context 'filter collections' do
    let(:mug) { create(:product) }
    let(:tshirt) { create(:product) }
    let(:variant) { create(:variant) }

    context 'variant has more than one collection' do
      before { variant.collections.push [mug, tshirt] }

      it 'returns both products' do
        expect(variant.collections_for([mug, tshirt])).to include(mug)
        expect(variant.collections_for([mug, tshirt])).to include(tshirt)
      end

      it { expect(variant).to be_an_item }
    end

    context 'variant no collection' do
      it 'returns both products' do
        variant.collections_for([mug, tshirt]).should be_empty
      end
    end
  end
end
