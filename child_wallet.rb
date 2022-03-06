require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)


class Child_wallet
  def initialize(master, number, depth = 1)
    @master = master
    @number = number
    @depth = depth

    @node = @master.node_for_path "m/#{number}/#{depth}"
  end

  def private_key
    @node.private_key.to_s
  end

  def address
    @node.to_address
  end
end
