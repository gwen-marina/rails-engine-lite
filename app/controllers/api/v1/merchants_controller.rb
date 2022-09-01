class Api::V1::MerchantsController < ApplicationController 
  def index
    render json: MerchantSerializer.format_merchants(Merchant.all)
  end

  def show 
    render json: MerchantSerializer.single_merchant(Merchant.find(params[:id]))
  end

 def find
    if params[:name].nil? 
      render status: 400
    else
      merchant = Merchant.find_by_name(params[:name])
      if !merchant.nil?
        render json: MerchantSerializer.single_merchant(merchant)
      else
        render json: MerchantSerializer.no_merchant
      end
    end
  end
end