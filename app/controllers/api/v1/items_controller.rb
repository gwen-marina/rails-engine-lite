class Api::V1::ItemsController < ApplicationController 
  def index
    render json: ItemSerializer.format_items(Item.all)
  end

  def show 
    item = Item.find(params[:id])
    render json: ItemSerializer.single_item(item)
  end

  def create
    item = Item.create(item_params) 
    render json: ItemSerializer.single_item(item), status: :created
  end

  def update
    item = Item.update(params[:id], item_params)
    if item.save
      render json: ItemSerializer.single_item(item)
    else
      render status: 404
    end
  end

  def destroy 
    item = Item.find(params[:id])
    render json: Item.destroy(params[:id]), status: 204
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end