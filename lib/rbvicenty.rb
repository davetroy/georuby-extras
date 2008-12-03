module GeoRuby
  module SimpleFeatures
    #Represents a point. It is in 3D if the Z coordinate is not +nil+.
    class Point < Geometry
      def ellipsoidal_distance2(point, a = 6378137.0, b = 6356752.3142)
        deg_to_rad = 0.0174532925199433
        
        f = (a-b) / a
        l = (point.lon - lon) * deg_to_rad
        
        u1 = Math.atan((1-f) * Math.tan(lat * deg_to_rad ))
        u2 = Math.atan((1-f) * Math.tan(point.lat * deg_to_rad))
        sinU1 = Math.sin(u1)
        cosU1 = Math.cos(u1)
        sinU2 = Math.sin(u2)
        cosU2 = Math.cos(u2)
  
        puts "sinU1, cosU1 = #{sinU1}, #{cosU1}"
        puts "sinU2, cosU2 = #{sinU2}, #{cosU2}"
        puts "L = #{l}"
        lambda = l
        lambdaP = 2 * Math::PI
        iterLimit = 20
        
        while (lambda-lambdaP).abs > 1e-12 && --iterLimit>0
          sinLambda = Math.sin(lambda)
          cosLambda = Math.cos(lambda)
          puts "sinLambda, cosLambda = #{sinLambda}, #{cosLambda}"
          sinSigma = Math.sqrt((cosU2*sinLambda) * (cosU2*sinLambda) + (cosU1*sinU2-sinU1*cosU2*cosLambda) * (cosU1*sinU2-sinU1*cosU2*cosLambda))
          
          return 0 if sinSigma == 0 #coincident points
          
          cosSigma = sinU1*sinU2 + cosU1*cosU2*cosLambda
          sigma = Math.atan2(sinSigma, cosSigma)
          sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma
          cosSqAlpha = 1 - sinAlpha*sinAlpha
          cos2SigmaM = cosSigma - 2*sinU1*sinU2/cosSqAlpha
          
          cos2SigmaM = 0 if (cos2SigmaM.nan?) #equatorial line: cosSqAlpha=0

          c = f/16*cosSqAlpha*(4+f*(4-3*cosSqAlpha))
          lambdaP = lambda
          lambda = l + (1-c) * f * sinAlpha * (sigma + c * sinSigma * (cos2SigmaM + c * cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM)))
        end
        return NaN if iterLimit==0 #formula failed to converge

        puts "lambdaP, lambda = #{lambdaP}, #{lambda}"
        uSq = cosSqAlpha * (a*a - b*b) / (b*b)
        a_bis = 1 + uSq/16384*(4096+uSq*(-768+uSq*(320-175*uSq)))
        b_bis = uSq/1024 * (256+uSq*(-128+uSq*(74-47*uSq)))
        deltaSigma = b_bis * sinSigma*(cos2SigmaM + b_bis/4*(cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)- b_bis/6*cos2SigmaM*(-3+4*sinSigma*sinSigma)*(-3+4*cos2SigmaM*cos2SigmaM)))
      
        b*a_bis*(sigma-deltaSigma)
      end
    end
  end
end