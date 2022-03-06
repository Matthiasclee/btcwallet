require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)


class Wallet
  def initialize(opts = {from: :new})
    if opts[:from] == :seedfile
      @master = MoneyTree::Master.new seed: File.read(opts[:seedfile])
      @master_private_key = @master.private_key.to_s
      @master_address = @master.to_address
      @master_seed = @master.seed
    elsif opts[:from] == :new
      @master = MoneyTree::Master.new
      @master_private_key = @master.private_key.to_s
      @master_address = @master.to_address
      @master_seed = @master.seed
    end
  end

  def generate_children(number, depth=1)
    children = []
    number.times do |num|
      node = @master.node_for_path "m/#{num}/#{depth}"
      children << node
    end

    return children
  end

  def generate_child(number=1, depth=1)
    return self.generate_children(number, depth)[0]
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
