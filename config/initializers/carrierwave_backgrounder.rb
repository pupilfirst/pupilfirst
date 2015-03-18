CarrierWave::Backgrounder.configure do |c|
  c.backend :delayed_job, queue: :carrierwave
  # c.backend :resque, queue: :carrierwave
  # c.backend :sidekiq, queue: :carrierwave
  # c.backend :girl_friday, queue: :carrierwave
  # c.backend :sucker_punch, queue: :carrierwave
  # c.backend :qu, queue: :carrierwave
  # c.backend :qc
end

# It is important to configure sucker_punch after carrierwave_backgrounder
# SuckerPunch.config do
#   queue name: :carrierwave, worker: CarrierWave::Workers::StoreAsset, size: 2
# end
