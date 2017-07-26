web: bundle exec puma -C config/puma.rb
worker: rake jobs:work
vocalist: rake lita:vocalist
low_priority_worker: QUEUE=low_priority rake jobs:work
