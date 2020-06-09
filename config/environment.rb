require 'bundler'
Bundler.require

configure :production do
  set :database, ENV['DATABASE_URL']
end