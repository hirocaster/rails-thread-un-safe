require 'net/http'
require 'json'

def increment_counter
  uri = URI('http://localhost:3000/counter/increment')
  response = Net::HTTP.get(uri)
  JSON.parse(response)['count']
end

threads = 100.times.map do
  Thread.new { increment_counter }
end

final_counts = threads.map(&:value)

puts "Final count: #{final_counts.last}"
puts "Expected count: 100"
puts "Actual unique counts: #{final_counts.uniq.sort}"
