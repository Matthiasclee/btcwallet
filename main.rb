require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require './wallet.rb'
require "./cli_interface.rb"

R::S.clear
R::Cr.go_to_pos(0,0)

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

  R::S.clear
  R::Cr.go_to_pos(0,0)

  cli_interface wallet

elsif option == 2
  
  print "Wallet file: "
  file = $stdin.gets.chomp
  
  wallet = Wallet.new(from: :seedfile, seedfile: file)

  R::S.clear
  R::Cr.go_to_pos(0,0)

  cli_interface wallet

else
  puts "Invalid option"
  exit
end
