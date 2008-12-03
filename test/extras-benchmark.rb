require 'rubygems'
require 'geo_ruby'
require "#{File.dirname(__FILE__)}/../lib/georuby-extras"
require 'benchmark'

include GeoRuby::SimpleFeatures

@home = Point.from_lon_lat(-76.511,39.024)
@nyc = Point.from_lon_lat(-73.5,40.2)

Benchmark.bmbm(30) do |bm|
  bm.report("   c distance") {100000.times { @home.ellipsoidal_distance(@nyc) }}
  bm.report("ruby distance") {100000.times { @home.orig_ellipsoidal_distance(@nyc) }}
end