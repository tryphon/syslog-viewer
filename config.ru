require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default, :production)
$: << File.expand_path("../lib", __FILE__)

require 'log_access'
run LogAccess::Application.new
