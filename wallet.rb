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
