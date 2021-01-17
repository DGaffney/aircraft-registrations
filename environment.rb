require 'pry'
require 'sinatra'
require 'sidekiq'
require 'sidekiq/api'
require 'json'
require 'nokogiri'
require 'restclient'
require 'mongoid'
require 'dgaff'
Mongoid.load!("mongoid.yml", :development)
$redis = Redis.new
Dir[File.dirname(__FILE__) + '/handlers/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/extensions/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/models/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/tasks/*.rb'].each {|file| require file }
