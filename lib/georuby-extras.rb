require 'geo_ruby'
require "#{File.dirname(__FILE__)}/../ext/vincenty"

module GeoRuby
  module SimpleFeatures
    class Point < Geometry
    
      alias_method :orig_ellipsoidal_distance, :ellipsoidal_distance

      # Implementation of the Vincenty 'distance' formula to find the ellipsoidal distance between points
      # As per implementation by Chris Veness (http://www.movable-type.co.uk/scripts/latlong-vincenty.html)
      # Default a/b values are for the WGS84 ellipsoid - other values may be specified
      def ellipsoidal_distance(point, a = 6378137.0, b = 6356752.3142)
        Vincenty.distance(x.to_f, y.to_f, point.x.to_f, point.y.to_f, a.to_f, b.to_f)
      end

      # Implementation of the Vincenty 'direct' formula to find a point based on a bearing and distance
      # As per implementation by Chris Veness (http://www.movable-type.co.uk/scripts/latlong-vincenty-direct.html)
      # Default a/b values are for the WGS84 ellipsoid - other values may be specified
      def point_at_bearing_and_distance(bearing=0.0, distance=0.0, a = 6378137.0, b = 6356752.3142)
        Point.from_coordinates(Vincenty.point_from_lon_lat(lon.to_f,lat.to_f,bearing.to_f,distance.to_f,a.to_f,b.to_f))
      end
      
    end
    
  end
end