require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require './wallet.rb'

def cli_interface(wallet)
  options = {
    99 => "Exit",
    1 => "Wallet address",
    2 => "Private key",
    3 => "Generate child wallet",
    4 => "Generate QR code for address",
    5 => "Get balance of wallet"
  }

  loop do
    options.keys.each do |opt|
      puts "#{opt}) #{options[opt]}"
    end

    option = $stdin.gets.chomp.to_i

    exit if option == 99

    if option == 1
      puts "\n#{wallet.address}"
    end
    
    if option == 2
      puts "\n#{wallet.private_key}"
    end

    if option == 3
      print "Wallet number: "
      number = $stdin.gets.chomp.to_i

      print "Wallet depth: "
      depth = $stdin.gets.chomp.to_i

      child = wallet.generate_child number, depth

      puts
      puts child.address
      puts child.private_key
    end

    if option == 4
      qr = RQRCode::QRCode.new(wallet.address).to_s.gsub("x", "█")

      puts qr
    end

    if option == 5
      response = Net::HTTP.get(URI("https://blockchain.info/balance?active=#{wallet.address}"))
      balance_satoshis = JSON.parse(response)[wallet.address]["final_balance"].to_i.to_f
      puts "\n#{balance_satoshis/100000000.to_f} BTC"
    end
  end
end

puts "1) New wallet"
puts "2) Load wallet"

option = $stdin.gets.chomp.to_i

if option == 1

  wallet = Wallet.new

  print "Do you want to save this wallet to a file? [Y/n] "
  save = $stdin.gets.chomp

  if save != "n"
    print "Filename: "
    File.write( $stdin.gets.chomp, wallet.seed )
  end

  cli_interface wallet

elsif option == 2
  
  print "Wallet file: "
  file = $stdin.gets.chomp
  
  wallet = Wallet.new(from: :seedfile, seedfile: file)

  cli_interface wallet

else
  puts "Invalid option"
  exit
end
