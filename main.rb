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
    5 => "Get balance of wallet",
    6 => "New TX"
  }

  loop do
    options.keys.each do |opt|
      puts "_.c:light-green._#{opt}) _.f:reset._#{options[opt]}".to_ftext
    end

    option = $stdin.gets.chomp.to_i

    exit if option == 99

    if option == 1
      puts "\n_.c:light-blue.__.f:bold._#{wallet.address}".to_ftext
    end
    
    if option == 2
      puts "\n_.c:green.__.f:faint._#{wallet.private_key}".to_ftext
    end

    if option == 3
      print "Wallet number: "
      number = $stdin.gets.chomp.to_i

      print "Wallet depth: "
      depth = $stdin.gets.chomp.to_i

      child = wallet.generate_child number, depth

      puts R::C.color :light_blue 
      puts "_.f:bold._#{child.address}".to_ftext
      print (R::C.color :green) + (R::F.faint)
      puts child.private_key
      print R::F.reset
    end

    if option == 4
      qr = RQRCode::QRCode.new(wallet.address).to_s.gsub("x", "██").gsub(" ", "  ")

      puts qr
    end

    if option == 5
      response = Net::HTTP.get(URI("https://blockchain.info/balance?active=#{wallet.address}"))
      balance_satoshis = JSON.parse(response)[wallet.address]["final_balance"].to_i.to_f
      bal = balance_satoshis/100000000.to_f
      puts "\n_.c:light-blue._#{"%.8f" % bal}_.f:reset._ BTC".to_ftext
    end

    if option == 6
      print "Amount of BTC to send: "
      amount = $stdin.gets.chomp.to_f

      print "Miner Fee: "
      fee = $stdin.gets.chomp.to_f

      print "Receiving Address: "
      to = $stdin.gets.chomp

      puts wallet.create_tx(amount: amount, fee: fee, to: to)
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
