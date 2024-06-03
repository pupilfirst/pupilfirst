class InboundWebhook < ApplicationRecord
  enum status: {
         pending: "pending",
         processing: "processing",
         processed: "processed",
         failed: "failed"
       }
end
