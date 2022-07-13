require 'argparse'
require 'csv'
require 'rbtext'
require 'net/http'
require 'json'

s = {
  i: {has_argument: true}
}

o = {
  "only-show-addresses-with-balance": {}
}

x=ArgsParser::Args.new(switches: s, options: o)

exit if !x.switches[:i]

t = CSV.parse(File.read(x.switches[:i]))
t.each do |w|
  print "."
  response = Net::HTTP.get(URI("https://blockchain.info/balance?active=#{w[0]}"))
  balance_satoshis = JSON.parse(response)[w[0]]["final_balance"].to_i.to_f
  bal = balance_satoshis/100000000.to_f
  if (x.options[:"only-show-addresses-with-balance"] && balance_satoshis != 0) || !x.options[:"only-show-addresses-with-balance"]
    puts "\n_.c:light-blue._#{w[0]}_.c:green.__.f:faint._ #{w[1]}_.f:reset.__.c:#{balance_satoshis == 0 ? "reset" : "green"}._ #{"%.8f" % bal}_.f:reset._ BTC".to_ftext
  end
end
