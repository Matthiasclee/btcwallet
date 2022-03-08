require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require './wallet.rb'

match = Regexp.new ARGV[0]

loop do
  wallet = Wallet.new
  addr = wallet.address

  puts addr if ARGV.include?('--printall')
  
  if addr.match?(match)
    key = wallet.private_key
    seed = wallet.seed
    
    puts "Match found!"

    puts "Address: #{wallet.address}"
    puts "Key: #{wallet.private_key}" if !ARGV.include?('--noprintkey')

    print "Seed file name: "
    file = $stdin.gets.chomp
    File.write(file, wallet.seed, mode: "wb")

    break
  end
end
