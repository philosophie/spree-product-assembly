class Spree::Admin::ItemsController < Spree::Admin::BaseController
  before_filter :find_product

  def index
    @items = @product.items
  end

  def remove
    @item = Spree::Variant.find(params[:id])
    @product.remove_item(@item)
    render 'spree/admin/items/update_items_table'
  end

  def set_count
    @item = Spree::Variant.find(params[:id])
    @product.set_item_count(@item, params[:count].to_i)
    render 'spree/admin/items/update_items_table'
  end

  def available
    if params[:q].blank?
      @available_products = []
    else
      query = "%#{params[:q]}%"
      @available_products = Spree::Product.search_can_be_item(query)
      @available_products.uniq!
    end
    respond_to do |format|
      format.html { render layout: false }
      format.js { render layout: false }
    end
  end

  def create
    @item = Spree::Variant.find(params[:item_id])
    qty = params[:item_count].to_i
    @product.add_item(@item, qty) if qty > 0
    render 'spree/admin/items/update_items_table'
  end

  private

  def find_product
    @product = Spree::Product.find_by(slug: params[:product_id])
  end

  def model_class
    Spree::ItemInCollection
  end
end
