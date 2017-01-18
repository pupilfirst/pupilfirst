module Paytm
  class ChecksumGenerationService
    require 'paytm/encryption_new_p_g'
    include Paytm::EncryptionNewPG

    def initialize(order_id:, customer_id:, amount:, phone:, email:)
      @params_list = {
        m_id: ENV['PATYM_MERCHANT_ID'],
        order_id: order_id,
        cust_id: customer_id,
        industry_type_id: ENV['PAYTM_INDUSTRY_TYPE_ID'],
        channel_id: ENV['PAYTM_CHANNEL_ID'],
        txn_amount: amount,
        msisdn: phone,
        email: email,
        website: ENV['PAYTM_MERCHANT_WEBSITE_URL']
      }
    end

    def generate_checksum
      new_pg_checksum(@params_list, ENV['PAYTM_MERCHANT_KEY']).delete("\n")
    end
  end
end
