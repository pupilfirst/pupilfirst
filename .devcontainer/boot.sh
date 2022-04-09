cp example.env .env
bundle install
rails db:setup
git config --global url."https://".insteadOf ssh://
yarn install
