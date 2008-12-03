#!/usr/bin/env ruby
require 'rubygems'
require 'test/unit'
require 'geo_ruby'
require "#{File.dirname(__FILE__)}/../lib/georuby-extras"

class GeoHashNativeTest < Test::Unit::TestCase
  
  include GeoRuby::SimpleFeatures

  def setup
    @home = Point.from_lon_lat(-76.511,39.024)
    @nyc = Point.from_lon_lat(-74,40.6)
  end
  
  def test_distance
    assert_in_delta 277195.5104, @home.ellipsoidal_distance(@nyc), 0.001
  end
  
  def test_orig_distance
    assert_in_delta 277195.5104, @home.orig_ellipsoidal_distance(@nyc), 0.001
  end

  def test_bearing_from_point
    dest = @home.point_at_bearing_and_distance(91.0, 130000.0)
    assert_in_delta -75.0106, dest.x, 0.0001
    assert_in_delta 38.9939, dest.y, 0.0001
  end
  
  # This test is basically identical to those in georuby; to confirm compatibility
  def test_point_distance
    point1 = Point.from_x_y(0,0)
    point2 = Point.from_x_y(3,4)
    assert_equal(5,point1.euclidian_distance(point2))
    
    assert_in_delta(554058.924,point1.ellipsoidal_distance(point2),0.001)
    assert_in_delta(554058.924,point1.orig_ellipsoidal_distance(point2),0.001)
         
    assert_in_delta(555811.68,point1.spherical_distance(point2),0.01)
  end
  
end