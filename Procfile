web: bundle exec passenger start -p $PORT --nginx-config-template config/nginx.conf.erb --max-pool-size $MAX_POOL_SIZE
worker: rake jobs:work
