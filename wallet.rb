require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)
require './child_wallet.rb'


class Wallet
  include Bitcoin::Builder

  def initialize(opts = {from: :new})
    if opts[:from] == :seedfile
      @master = MoneyTree::Master.new seed: File.read(opts[:seedfile])
      @master_private_key = @master.private_key.to_s
      @master_address = @master.to_address
      @master_seed = @master.seed
      @btc_ruby_key = Bitcoin::Key.from_base58(@master_private_key)
    elsif opts[:from] == :new
      @master = MoneyTree::Master.new
      @master_private_key = @master.private_key.to_s
      @master_address = @master.to_address
      @master_seed = @master.seed
      @btc_ruby_key = Bitcoin::Key.from_base58(@master_private_key)
    end
  end

  def generate_children(number, depth=1)
    children = []
    number.times do |num|
      child = Child_wallet.new(@master, num, depth)
      children << child
    end

    return children
  end

  def generate_child(number=1, depth=1)
    return self.generate_children(number, depth)[0]
  end

  def create_tx(opts)
    addrdata = Net::HTTP.get(URI("https://blockchain.info/rawaddr/#{self.address}")) 
    transactions = JSON.parse(addrdata)["txs"]
    amount_found = 0

    viable_txns = []

    transactions.each do |txn|
      hash = txn["hash"]
      
      txn["out"].each do |out|
        if out["addr"] == self.address && !out["spent"] && amount_found < opts[:amount]
          viable_txns << {hash: hash, num: out["n"]}
          amount_found = amount_found + out["value"]
        end
      end
    end

    key = Bitcoin::Key.from_base58(self.private_key)

    new_tx = build_tx do |t|

      viable_txns.each do |tx|
        t.input do |i|
          rawtx = Net::HTTP.get(URI("https://blockchain.info/rawtx/#{tx[:hash]}?format=hex"))

          i.prev_out Bitcoin::Protocol::Tx.new([rawtx].pack('H*'))

          i.prev_out_index tx[:num]

          i.signature_key key
        end
      end

      # add an output that sends some bitcoins to another address
      t.output do |o|
        o.value 50000000 # 0.5 BTC in satoshis
        o.script {|s| s.recipient "1Q8gxrq8uitsWSgZBqV9mfTHzK4vBKvwz" }
      end

      # add another output spending the remaining amount back to yourself
      # if you want to pay a tx fee, reduce the value of this output accordingly
      # if you want to keep your financial history private, use a different address
      t.output do |o|
        o.value 49000000 # 0.49 BTC, leave 0.01 BTC as fee
        o.script {|s| s.recipient key.addr }
      end

    end

    return new_tx.to_json
  end

  def private_key
    @master_private_key.to_s
  end

  def address
    @master_address
  end

  def seed
    @master_seed
  end
end
