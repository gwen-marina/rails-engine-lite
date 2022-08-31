require 'rails_helper'

RSpec.describe "Item's API" do
  it "sends a list of all items" do 
    merchant = Merchant.create!(name: Faker::Company.name)
    merchant_items = create_list(:item, 10, merchant_id: merchant.id)

    get '/api/v1/items'

    expect(response).to be_successful

    items_response = JSON.parse(response.body, symbolize_names: true)
    items = items_response[:data]

    expect(items.count).to eq(10)

    items.each do |item|
      expect(item).to have_key(:id)
      expect(item[:id]).to be_a(String)

      expect(item[:type]).to eq('item')

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_a String

      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes][:description]).to be_a String

      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes][:unit_price]).to be_a Float

      expect(item[:attributes]).to have_key(:merchant_id)
      expect(item[:attributes][:merchant_id]).to be_a Integer
    end
  end

  it "can get one item" do 
    merchant = Merchant.create!(name: Faker::Company.name)
    merchant_items = create_list(:item, 10, merchant_id: merchant.id)
    item = Item.first
  
    get "/api/v1/items/#{item.id}"
   
    expect(response).to be_successful

    items_response = JSON.parse(response.body, symbolize_names: true)
    item = items_response[:data]

    expect(item).to be_a(Hash)
    expect(item).to have_key(:id)
    expect(item[:id]).to be_a String
    expect(item[:attributes]).to have_key(:name)
    expect(item[:attributes][:name]).to be_a String
    expect(item[:attributes]).to have_key(:description)
    expect(item[:attributes][:description]).to be_a String
    expect(item[:attributes]).to have_key(:unit_price)
    expect(item[:attributes][:unit_price]).to be_a Float
    expect(item[:attributes]).to have_key(:merchant_id)
    expect(item[:attributes][:merchant_id]).to be_a Integer
    expect(item[:type]).to eq("item")
  end

  it "can create a new item" do 
    merchant = Merchant.create!(name: Faker::Company.name)
    
    item_params = ({
                  name: 'thing',
                  description: 'this is a thing',
                  unit_price: 20.22,
                  merchant_id: merchant.id
                })

    headers = {"CONTENT_TYPE" => "application/json"}

  
    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
    created_item = Item.last

    expect(response).to be_successful
    expect(created_item.name).to eq(item_params[:name])
    expect(created_item.description).to eq(item_params[:description])
    expect(created_item.unit_price).to eq(item_params[:unit_price])
    expect(created_item.merchant_id).to eq(item_params[:merchant_id])
  end
end