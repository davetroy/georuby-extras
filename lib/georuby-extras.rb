require "#{File.dirname(__FILE__)}/../ext/vicenty"

module GeoRuby
  module SimpleFeatures
    class Point < Geometry
    
      alias_method :orig_ellipsoidal_distance, :ellipsoidal_distance
      def ellipsoidal_distance(point, a = 6378137.0, b = 6356752.3142)
        Vicenty.distance(x, y, point.x, point.y, a, b)
      end
      
      def point_at_bearing_and_distance(bearing=0.0, distance=0.0, a = 6378137.0, b = 6356752.3142)
        Point.from_coordinates(Vicenty.point_from_lon_lat(lon,lat,bearing,distance,a,b))
      end
    end
  end
end