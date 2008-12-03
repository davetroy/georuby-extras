#!/usr/bin/env ruby
require 'rubygems'
require 'test/unit'
require 'geo_ruby'
require "#{File.dirname(__FILE__)}/../lib/georuby-extras"

class GeoHashNativeTest < Test::Unit::TestCase
  
  include GeoRuby::SimpleFeatures

  def setup
    @home = Point.from_lon_lat(-76.511,39.024)
    @nyc = Point.from_lon_lat(-73.5,40.2)
  end
  
  def test_distance
    assert_in_delta 289643.11, @home.ellipsoidal_distance(@nyc), 1
  end
  
  def test_orig_distance
    assert_in_delta 289643.11, @home.orig_ellipsoidal_distance(@nyc), 1
  end
  
  # 
  # def test_bearing_from_point
  #   dest = point_from_lon_lat(@home.x, @home.y, 91.0, 130000.0)
  #   p dest.join(',')
  # end
  
  require 'benchmark'
  def test_multiple
    Benchmark.bmbm(30) do |bm|
      bm.report("   c distance") {30000.times { test_distance }}
      bm.report("ruby distance") {30000.times { test_orig_distance }}
    end
  end
end