class InboundWebhook < ApplicationRecord
  belongs_to :school

  enum status: {
         pending: "pending",
         processing: "processing",
         processed: "processed",
         failed: "failed"
       }
end
