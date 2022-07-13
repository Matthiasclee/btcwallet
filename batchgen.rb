require 'rubygems'
require 'argparse'
require 'bundler/setup'
Bundler.require(:default)
require './wallet.rb'

s = {
  n: {has_argument: true},
  o: {has_argument: true}
}

o = {
  overwrite: {}
}

x=ArgsParser::Args.new(switches: s, options: o)
output_file = 'wallets.csv'
output_file = x.switches[:o] if x.switches[:o]
if x.options[:overwrite]
  File.write(output_file, "")
end

x.switches[:n].to_i.times do
  print(".")
  wallet = Wallet.new
  File.write(output_file, "\"#{wallet.address}\",\"#{wallet.private_key}\"\n", mode: 'a')
end
