require './wallet.rb'

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

elsif option == 2
  
  print "Wallet file: "
  file = $stdin.gets.chomp
  
  wallet = Wallet.new(from: :seedfile, seedfile: file)

else
  puts "Invalid option"
  exit
end
