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
    response = Net::HTTP.get(URI("https://blockchain.info/balance?active=#{self.address}"))
    balance_satoshis = JSON.parse(response)[self.address]["final_balance"].to_i.to_f

    addrdata = Net::HTTP.get(URI("https://blockchain.info/rawaddr/#{self.address}")) 
    transactions = JSON.parse(addrdata)["txs"].reverse

    viable_txns = []

    transactions.each do |txn|
      hash = txn["hash"]
      
      txn["out"].each do |out|
        if out["addr"] == self.address
          viable_txns << {hash: hash, num: out["n"]}
        end
      end
    end

    tx = viable_txns[viable_txns.length-1]

    key = Bitcoin::Key.from_base58(self.private_key)

    new_tx = build_tx do |t|

      t.input do |i|
        rawtx = Net::HTTP.get(URI("https://blockchain.info/rawtx/#{tx[:hash]}?format=hex"))

        i.prev_out Bitcoin::Protocol::Tx.new([rawtx].pack('H*'))

        i.prev_out_index tx[:num]

        i.signature_key key
      end

      # add an output that sends some bitcoins to another address
      t.output do |o|
        o.value (opts[:amount] * 100000000.0).to_i
        o.script {|s| s.recipient opts[:to] }
      end

      # add another output spending the remaining amount back to yourself
      # if you want to pay a tx fee, reduce the value of this output accordingly
      # if you want to keep your financial history private, use a different address
      t.output do |o|
        o.value (balance_satoshis - (opts[:amount] * 100000000.0) - (opts[:fee].to_f)).to_i
        o.script {|s| s.recipient key.addr }
      end

    end

    return new_tx.to_payload.bth
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
