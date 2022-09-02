require 'rails_helper'

RSpec.describe "Item's API" do
  it 'sends a list of all items' do 
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

  it 'can get one item' do 
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

  it 'can create a new item' do 
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

  it 'returns an error if attribute is missing from create or any attributes that are not allowed are sent' do
    merchant = create_list(:merchant, 1).first
    item_params = ({
                  name: "doodad",
                  unit_price: 2.00,
                  merchant_id: merchant.id,
                  extra: "stuff"
                })

    headers = {"CONTENT_TYPE" => "application/json"}

    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

    expect(response).to_not be_successful
    expect(response.status).to eq(400)
  end

  it 'can edit an existing item' do
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

  it 'returns an error if trying to update an item that does not exist' do
    merchant = create(:merchant)

    item_params = ({
      name: 'thing',
      description: "a thing",
      unit_price: 1.00,
      merchant_id: merchant.id
    })

    headers = { 'CONTENT_TYPE' => 'application/json' }
    post '/api/v1/items', headers: headers, params: JSON.generate(item: item_params)

    item = Item.last

    new_item_params = ({
                    description: "It's an even better thing than before, really it is."
                    })

    headers = { 'CONTENT_TYPE' => 'application/json' }
    patch '/api/v1/items/2', headers: headers, params: JSON.generate(item: new_item_params)

    expect(response).to_not be_successful
    expect(response.status).to eq(404)

    expect(item.description).to eq(item_params[:description])
  end

  it 'can delete an item' do 
    merchant = create(:merchant)
    item = create(:item, merchant_id: merchant.id)

    delete "/api/v1/items/#{item.id}"

    expect(response).to be_successful
    expect(response.status).to eq(204)
    expect(response.status).to_not eq(201)
    expect(Item.count).to be(0)
    expect(Item.exists?(item.id)).to be false 
  end

  it 'can get the merchant data for a given item id' do 
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

  it 'can find all items based on search criteria' do
    merchant = create(:merchant)
    item_1 = Item.create(name: "thing one", description: "an item", unit_price: 2.00, merchant_id: merchant.id)
    item_2 = Item.create(name: "thingamajig", description: "an item", unit_price: 3.00, merchant_id: merchant.id)
    item_3 = Item.create(name: "thingydo", description: "an item", unit_price: 1.00, merchant_id: merchant.id)
    item_4 = Item.create(name: "junk", description: "a junk item", unit_price: 1.00, merchant_id: merchant.id)
  
    get "/api/v1/items/find_all?name=thing"
  
    expect(response).to be_successful
    expect(response.status).to eq(200)
    
    items_response = JSON.parse(response.body, symbolize_names: true)
    items_results = items_response[:data]

    expect(items_results).to be_an Array
    expect(items_results.count).to eq(3)
    
    items_results.each do |item|
        expect(item).to have_key :id
        expect(item[:id]).to be_a String

        expect(item).to have_key :type
        expect(item[:type]).to eq('item')

        expect(item).to have_key :attributes

        expect(item[:attributes]).to have_key :name
        expect(item[:attributes][:name]).to be_a String

        expect(item[:attributes]).to have_key :description
        expect(item[:attributes][:description]).to be_a String

        expect(item[:attributes]).to have_key :unit_price
        expect(item[:attributes][:unit_price]).to be_a Float

        expect(item[:attributes]).to have_key :merchant_id
        expect(item[:attributes][:merchant_id]).to be_a Integer
    end
  end

  it 'returns an empty array if no search results found' do
    merchant = create(:merchant)
    item_1 = Item.create(name: "thing one", description: "an item", unit_price: 2.00, merchant_id: merchant.id)
    item_2 = Item.create(name: "thingamajig", description: "an item", unit_price: 3.00, merchant_id: merchant.id)
    item_3 = Item.create(name: "thingydo", description: "an item", unit_price: 1.00, merchant_id: merchant.id)
    item_4 = Item.create(name: "junk", description: "a junk item", unit_price: 1.00, merchant_id: merchant.id)

    get "/api/v1/items/find_all?name=stuff"

    expect(response).to be_successful

    items_response = JSON.parse(response.body, symbolize_names: true)
    items_results = items_response[:data]

    expect(items_results).to be_an Array
    expect(items_results.empty?).to be true
    expect(items_results.count).to eq(0)
  end
end