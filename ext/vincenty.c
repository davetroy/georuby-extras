// geohash-native.c
// (c) 2008 David Troy
// dave@roundhousetech.com
//
// Based on Javascript code (c) by Chris Veness
// http://www.movable-type.co.uk/scripts/latlong-vincenty.html
// http://www.movable-type.co.uk/scripts/latlong-vincenty-direct.html
// 
// Derived from algorithms by T. Vincenty, 1975
//
// (The MIT License)
// 
// Copyright (c) 2008 David Troy, Roundhouse Technologies LLC
// 
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// 'Software'), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#include "ruby.h"
#include <math.h>
#include <ctype.h>

#define DEG_TO_RAD	0.0174532925199433
#define PI					3.14159265358979

static VALUE rb_mVincenty;

static VALUE distance(VALUE self, VALUE rb_lon1, VALUE rb_lat1, VALUE rb_lon2, VALUE rb_lat2, VALUE rb_a, VALUE rb_b) {

	Check_Type(rb_lon1, T_FLOAT);
	Check_Type(rb_lat1, T_FLOAT);
	Check_Type(rb_lon2, T_FLOAT);
	Check_Type(rb_lat2, T_FLOAT);
	Check_Type(rb_a, T_FLOAT);
	Check_Type(rb_b, T_FLOAT);

	double lon1 = RFLOAT(rb_lon1)->value;
	double lat1 = RFLOAT(rb_lat1)->value;
	double lon2 = RFLOAT(rb_lon2)->value;
	double lat2 = RFLOAT(rb_lat2)->value;
	double a = RFLOAT(rb_a)->value;
	double b = RFLOAT(rb_b)->value;

	double sinLambda, cosLambda, sinSigma, cosSigma, sigma, sinAlpha, cosSqAlpha, cos2SigmaM, C;
	
	double f = (a-b) / a;
  double L = (lon2-lon1) * DEG_TO_RAD;
  double U1 = atan((1-f) * tan(lat1 * DEG_TO_RAD));
  double U2 = atan((1-f) * tan(lat2 * DEG_TO_RAD));
	double sinU1 = sin(U1), cosU1 = cos(U1);
  double sinU2 = sin(U2), cosU2 = cos(U2);

	int iterLimit = 20;
  double lambda = L, lambdaP=2*PI;
  while ((fabs(lambda-lambdaP) > 1e-12 && --iterLimit>0)) {
		sinLambda = sin(lambda); cosLambda = cos(lambda);
    sinSigma = sqrt((cosU2*sinLambda) * (cosU2*sinLambda) + (cosU1*sinU2-sinU1*cosU2*cosLambda) * (cosU1*sinU2-sinU1*cosU2*cosLambda));
    if (sinSigma==0) return rb_float_new(0);  // co-incident points
    cosSigma = sinU1*sinU2 + cosU1*cosU2*cosLambda;
    sigma = atan2(sinSigma, cosSigma);
    sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma;
    cosSqAlpha = 1 - sinAlpha*sinAlpha;
    cos2SigmaM = cosSigma - 2*sinU1*sinU2/cosSqAlpha;
    if (isnan(cos2SigmaM)) cos2SigmaM = 0;  // equatorial line: cosSqAlpha=0 (§6)
    C = f/16*cosSqAlpha*(4+f*(4-3*cosSqAlpha));
    lambdaP = lambda;
    lambda = L + (1-C) * f * sinAlpha * (sigma + C*sinSigma*(cos2SigmaM+C*cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)));
  }

	if (iterLimit==0) return Qnil;  // formula failed to converge

  double uSq = cosSqAlpha * (a*a - b*b) / (b*b);
  double A = 1 + uSq/16384.0*(4096+uSq*(-768+uSq*(320-175*uSq)));
  double B = uSq/1024 * (256+uSq*(-128+uSq*(74-47*uSq)));
  double deltaSigma = B*sinSigma*(cos2SigmaM+B/4*(cosSigma*(-1+2*cos2SigmaM*cos2SigmaM) -
    B/6*cos2SigmaM*(-3+4*sinSigma*sinSigma)*(-3+4*cos2SigmaM*cos2SigmaM)));

	double s = b*A*(sigma-deltaSigma);
	
	return rb_float_new(s);
}

static VALUE point_from_lon_lat(VALUE self, VALUE rb_lon1, VALUE rb_lat1, VALUE rb_bearing, VALUE rb_distance, VALUE rb_a, VALUE rb_b) {
	Check_Type(rb_lon1, T_FLOAT);
	Check_Type(rb_lat1, T_FLOAT);
	Check_Type(rb_bearing, T_FLOAT);
	Check_Type(rb_distance, T_FLOAT);
	Check_Type(rb_a, T_FLOAT);
	Check_Type(rb_b, T_FLOAT);
	
	VALUE ret;

	double lon1 = RFLOAT(rb_lon1)->value;
	double lat1 = RFLOAT(rb_lat1)->value;
	double brng = RFLOAT(rb_bearing)->value;
	double s = RFLOAT(rb_distance)->value;
	double a = RFLOAT(rb_a)->value;
	double b = RFLOAT(rb_b)->value;
	
	double f = (a-b) / a;
  double alpha1 = brng * DEG_TO_RAD;
  double sinAlpha1 = sin(alpha1), cosAlpha1 = cos(alpha1);
  
  double tanU1 = (1-f) * tan(lat1 * DEG_TO_RAD);
  double cosU1 = 1 / sqrt((1 + tanU1*tanU1)), sinU1 = tanU1*cosU1;
  double sigma1 = atan2(tanU1, cosAlpha1);
  double sinAlpha = cosU1 * sinAlpha1;
  double cosSqAlpha = 1 - sinAlpha*sinAlpha;
  double uSq = cosSqAlpha * (a*a - b*b) / (b*b);
  double A = 1 + uSq/16384*(4096+uSq*(-768+uSq*(320-175*uSq)));
  double B = uSq/1024 * (256+uSq*(-128+uSq*(74-47*uSq)));
  
  double sigma = s / (b*A), sigmaP = 2*PI;
	double cos2SigmaM, sinSigma, deltaSigma, cosSigma;
  while (fabs(sigma-sigmaP) > 1e-12) {
    cos2SigmaM = cos(2*sigma1 + sigma);
    sinSigma = sin(sigma), cosSigma = cos(sigma);
    deltaSigma = B*sinSigma*(cos2SigmaM+B/4*(cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)-
      B/6*cos2SigmaM*(-3+4*sinSigma*sinSigma)*(-3+4*cos2SigmaM*cos2SigmaM)));
    sigmaP = sigma;
    sigma = s / (b*A) + deltaSigma;
  }

  double tmp = sinU1*sinSigma - cosU1*cosSigma*cosAlpha1;
  double lat2 = atan2(sinU1*cosSigma + cosU1*sinSigma*cosAlpha1, (1-f)*sqrt(sinAlpha*sinAlpha + tmp*tmp));
  double lambda = atan2(sinSigma*sinAlpha1, cosU1*cosSigma - sinU1*sinSigma*cosAlpha1);
  double C = f/16*cosSqAlpha*(4+f*(4-3*cosSqAlpha));
  double L = lambda - (1-C) * f * sinAlpha * (sigma + C*sinSigma*(cos2SigmaM+C*cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)));

  double revAz = atan2(sinAlpha, -tmp);  // final bearing

	ret = rb_ary_new2(2); /* [lon, lat] */
	rb_ary_store(ret, 0, rb_float_new(lon1+L/DEG_TO_RAD));
	rb_ary_store(ret, 1, rb_float_new(lat2/DEG_TO_RAD));

	return ret;
}

void Init_vincenty()
{
	rb_mVincenty = rb_define_module("Vincenty");
	rb_define_module_function(rb_mVincenty, "distance", distance, 6);
	rb_define_module_function(rb_mVincenty, "point_from_lon_lat", point_from_lon_lat, 6);
}

// end
