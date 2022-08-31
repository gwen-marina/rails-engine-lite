require 'rails_helper'

RSpec.describe "Merchant's API" do 
  it "sends a list of merchants" do
    create_list(:merchant, 4)

    get '/api/v1/merchants'

    expect(response).to be_successful

    merchants_response = JSON.parse(response.body, symbolize_names: true)
    merchants = merchants_response[:data]

    expect(merchants.count).to eq(4)
    
    merchants.each do |merchant|
      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_a(String)

      expect(merchant[:type]).to eq('merchant')

      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a String
    end
  end

  it "can get one merchant by its id" do
    id = create(:merchant).id

    get "/api/v1/merchants/#{id}"
    
    expect(response).to be_successful

    merchant_response = JSON.parse(response.body, symbolize_names: true)
    merchant = merchant_response[:data]

    expect(merchant).to be_a(Hash)
    expect(merchant).to have_key(:id)
    expect(merchant[:id]).to be_a String
    expect(merchant[:attributes]).to have_key(:name)
    expect(merchant[:attributes][:name]).to be_a String
    expect(merchant[:type]).to eq("merchant")
  end 

  it "can get all items for a given merchant id" do 
    merchant = Merchant.create!(name: Faker::Company.name)
    merchant_items = create_list(:item, 5, merchant_id: merchant.id)

    get "/api/v1/merchants/#{merchant.id}/items"
    
    merchant_response = JSON.parse(response.body, symbolize_names: true)
    items = merchant_response[:data]
  end
end