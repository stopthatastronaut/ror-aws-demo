#!/bin/bash

sudo add-apt-repository universe

sudo apt-get update

sudo apt-get install -y apache2

# Rails install script sourced from the RoR site.
sudo apt-get update
sudo apt-get install -y curl gpgv2 ruby-dev

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install -y yarn

gem install bundler

echo "setting up rails"

gem install rails -v 6.1.3.2

rails -v

echo "setting up a dummy file in WWW"

echo "<h1>hello world</h1>" | sudo tee /var/www/html/index.html