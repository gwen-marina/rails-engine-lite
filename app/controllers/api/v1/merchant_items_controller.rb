class Api::V1::MerchantItemsController < ApplicationController 
  def index
    if Merchant.exists?(params[:id])
      merchant = Merchant.find(params[:id])
      render json: ItemSerializer.format_items(merchant.items)
    else
      render status: 404
    end
  end

  def show 
    item = Item.find(params[:id])
    render json: MerchantSerializer.single_merchant(item.merchant)
  end
end

    