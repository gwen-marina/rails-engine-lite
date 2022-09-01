require 'rails_helper'

RSpec.describe "Item's API" do
  it "sends a list of all items" do 
    merchant = Merchant.create!(name: Faker::Company.name)
    merchant_items = create_list(:item, 10, merchant_id: merchant.id)

    get '/api/v1/items'

    expect(response).to be_successful
    expect(response.status).to eq(200)
    expect(response.status).to_not eq(400)
    
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
    expect(response.status).to eq(200)
    expect(response.status).to_not eq(404)

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
    expect(response.status).to eq(201)
    expect(response.status).to_not eq(204)
    expect(created_item.name).to eq(item_params[:name])
    expect(created_item.description).to eq(item_params[:description])
    expect(created_item.unit_price).to eq(item_params[:unit_price])
    expect(created_item.merchant_id).to eq(item_params[:merchant_id])
  end

  it "can edit an existing item" do
    merchant = create(:merchant)
    item = create(:item, merchant_id: merchant.id)

    previous_name = Item.name
    item_params = ({
                  name: 'balloon',
                  description: 'this is a balloon',
                  unit_price: 2.22,
                  merchant_id: merchant.id
                })
    headers = {"CONTENT_TYPE" => "application/json"}

    patch "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate({item: item_params})
    updated_item = Item.find(item.id)

    expect(response).to be_successful
    expect(response.status).to eq(200)
    expect(response.status).to_not eq(404)
    expect(updated_item.name).to_not eq(previous_name)
    expect(updated_item.name).to eq('balloon')
  end

  it "can delete an item" do 
    merchant = create(:merchant)
    item = create(:item, merchant_id: merchant.id)

    delete "/api/v1/items/#{item.id}"

    expect(response).to be_successful
    expect(response.status).to eq(204)
    expect(response.status).to_not eq(201)
    expect(Item.count).to be(0)
    expect(Item.exists?(item.id)).to be false 
  end

  it "can get the merchant data for a given item id" do 
    merchant = create(:merchant)
    item = create(:item, merchant_id: merchant.id)

    get "/api/v1/items/#{item.id}/merchant"
  
    expect(response).to be_successful
    expect(response.status).to eq(200)
    expect(response.status).to_not eq(404)
    expect(merchant.name).to be(merchant.name)

    merchant_response = JSON.parse(response.body, symbolize_names: true)
    return_merchant = merchant_response[:data]

    expect(return_merchant).to have_key(:id)
    expect(return_merchant[:id]).to be_a String

    expect(return_merchant).to have_key(:type)
    expect(return_merchant[:type]).to eq("merchant")

    expect(return_merchant[:attributes]).to have_key(:name)
    expect(return_merchant[:attributes][:name]).to be_a String
  end
end