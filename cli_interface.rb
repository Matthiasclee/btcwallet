$opt_blocks = {}
def opt(n, &block)
  $opt_blocks[n] = block
end
def call_opt(option, wallet)
  R::S.clear
  R::Cr.go_to_pos(0,0)
  $opt_blocks[option].call(wallet)
end
def n_opt(a)
end

def cli_interface(wallet)
  options = {
    1 => "Address",
    2 => "QR code",
    3 => "Wallet balance",
    4 => "Send BTC",
    6 => "_.c:red._Show private key".to_ftext,
    99 => "Exit"
  }

  loop do
    options.keys.sort.each do |opt|
      puts "_.c:light-green._#{opt}) _.f:reset._#{options[opt]}".to_ftext
    end

    option = $stdin.gets.chomp.to_i

    exit if option == 99

    call_opt option, wallet

  end
end

opt 1 do |wallet|
  puts "_.c:light-blue.__.f:bold._#{wallet.address}".to_ftext
end

opt 6 do |wallet|
  puts "_.c:green.__.f:faint._#{wallet.private_key}".to_ftext
end

n_opt 111 do |wallet|
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

opt 2 do |wallet|
  qr = RQRCode::QRCode.new(wallet.address).to_s.gsub("x", "██").gsub(" ", "  ")

  puts qr
end

opt 3 do |wallet|
  response = Net::HTTP.get(URI("https://blockchain.info/balance?active=#{wallet.address}"))
  balance_satoshis = JSON.parse(response)[wallet.address]["final_balance"].to_i.to_f
  bal = balance_satoshis/100000000.to_f
  puts "_.c:light-blue._#{"%.8f" % bal}_.f:reset._ BTC".to_ftext
end

opt 4 do |wallet|
  print "Amount of BTC to send: "
  amount = $stdin.gets.chomp.to_f

  print "Miner Fee (sats): "
  fee = $stdin.gets.chomp.to_f

  print "Receiving Address: "
  to = $stdin.gets.chomp

  puts wallet.create_tx(amount: amount, fee: fee, to: to)
end
