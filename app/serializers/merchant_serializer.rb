class MerchantSerializer
  def self.format_merchants(merchants)
    {
      data: merchants.map do |merchant|
        {
          id: merchant.id.to_s,
          type: "merchant",
          attributes: {
            name: merchant.name
          }
        }
      end
    }
  end

  def self.single_merchant(merchant)
    {
      data:
        {
          id: merchant.id.to_s,
          type: "merchant",
          attributes: {
            name: merchant.name
          }
        }
    }
  end

  def self.no_merchant
    {
      data: {}
    }
  end
end

