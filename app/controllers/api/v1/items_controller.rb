class Api::V1::ItemsController < ApplicationController 
  def index
    render json: ItemSerializer.format_items(Item.all)
  end

  def show 
    item = Item.find(params[:id])
    render json: ItemSerializer.single_item(item)
  end

  def create
    item = Item.new(item_params) 
    if item.save
      render json: ItemSerializer.single_item(item), status: :created
    else
      render status: 400
    end
  end

  def update
    if Item.exists?(params[:id])
      item = Item.find(params[:id])
      item.update(item_params)
      if item.save
        render json: ItemSerializer.single_item(item)
      else
        render status: 404
      end
    else
      render status: 404
    end
  end

  def destroy 
    item = Item.find(params[:id])
    render json: Item.destroy(params[:id]), status: 204
  end

  def find_all
    item = Item.find_all_by_name(params[:name])
    render json: ItemSerializer.format_items(item)
  end


  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end