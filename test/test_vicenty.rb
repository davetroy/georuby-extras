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
     
  def test_bearing_from_point
    dest = @home.point_at_bearing_and_distance(91.0, 130000.0)
    assert_in_delta -75.0106, dest.x, 0.0001
    assert_in_delta 38.9939, dest.y, 0.0001
  end

end