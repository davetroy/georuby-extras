require './test_vicenty.rb'
require 'benchmark'

def test_multiple
  Benchmark.bmbm(30) do |bm|
    bm.report("   c distance") {30000.times { test_distance }}
    bm.report("ruby distance") {30000.times { test_orig_distance }}
  end
end