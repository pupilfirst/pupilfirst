module Paytm
  class ChecksumGenerationService
    require 'paytm/encryption_new_p_g'
    include Paytm::EncryptionNewPG

    def initialize(order_id:, customer_id:, amount:, phone:, email:)
      @params_list = {
        "MID": ENV.fetch('PAYTM_MERCHANT_ID'),
        "ORDER_ID": order_id,
        "CUST_ID": customer_id,
        "INDUSTRY_TYPE_ID": ENV.fetch('PAYTM_INDUSTRY_TYPE_ID'),
        "CHANNEL_ID": ENV.fetch('PAYTM_CHANNEL_ID'),
        "TXN_AMOUNT": amount,
        "MSISDN": phone,
        "EMAIL": email,
        "WEBSITE": ENV.fetch('PAYTM_MERCHANT_WEBSITE_NAME')
      }
    end

    def generate_checksum
      new_pg_checksum(@params_list, ENV.fetch('PAYTM_MERCHANT_KEY')).delete("\n")
    end
  end
end
