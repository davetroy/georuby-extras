require "#{File.dirname(__FILE__)}/../ext/vicenty"

module GeoRuby
  module SimpleFeatures
    class Point < Geometry
      include Vicenty
      
      alias_method :orig_ellipsoidal_distance, :ellipsoidal_distance
      def ellipsoidal_distance(point, a = 6378137.0, b = 6356752.3142)
        distance(x, y, point.x, point.y, a, b)
      end
      
      def point_from_point()
    end
  end
end