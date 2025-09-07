/*
	Original shader by mrange (https://www.shadertoy.com/view/3ljyDD)
	Godot 3.5 port with customizable parameters by PmkExpert
	As much as possible of the original has been kept, including comments

	MIT License

*/

// License CC0: Hexagonal tiling + cog wheels
//  Nothing fancy, just hexagonal tiling + cog wheels

shader_type canvas_item;

uniform vec4 back_color : source_color = vec4(0.63, 0.63, 0.63, 1.0); //The background color
uniform vec4 gears_color : source_color = vec4(0.3, 0.3, 0.3, 1.0); //The gears color
uniform float base_zoom : hint_range (0.1, 1.0) = 1.0; //How much the gears are zoomed in
uniform float zoomSpeed : hint_range (0.0, 1.0) = 0.1; //How quickly the zoom effect cycles
uniform float GearSpeed : hint_range (-10.0, 10.0) = 1.0; //The gears speed; negative for opposite direction
uniform float ClockSpeed : hint_range (-10.0, 10.0) = 1.0; //The hands speed; negative to go back in time
//Some other values in the code can be changed, but are mostly details like the number of holes

mat2 MROT(float a){
	return mat2(vec2(cos(a),sin(a)),vec2(-sin(a),cos(a)));
}

float hash(in vec2 co) {
  return fract(sin(dot(co.xy ,vec2(12.9898,58.233))) * 13758.5453);
}

float pcos(float a) {
  return 0.5 + 0.5*cos(a);
}

void rot(inout vec2 p, float a) {
  float c = cos(a);
  float s = sin(a);
  p = vec2(c*p.x + s*p.y, -s*p.x + c*p.y);
}

float modPolar(inout vec2 p, float repetitions) {
  float angle = 2.0*PI/repetitions;
  float a = atan(p.y, p.x) + angle/2.;
  float r = length(p);
  float c = floor(a/angle);
  a = mod(a,angle) - angle/2.;
  p = vec2(cos(a), sin(a))*r;
  // For an odd number of repetitions, fix cell index of the cell in -x direction
  // (cell index would be e.g. -5 and 5 in the two halves of the cell):
  if (abs(c) >= (repetitions/2.0)) c = abs(c);
  return c;
}

float pmin(float a, float b, float k) {
  float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
  return mix( b, a, h ) - k*h*(1.0-h);
}

const vec2 sz       = vec2(1.0, sqrt(3.0));
const vec2 hsz      = 0.5*sz;
const float smallCount = 16.0;

vec2 hextile(inout vec2 p) {
  // See Art of Code: Hexagonal Tiling Explained!
  // https://www.youtube.com/watch?v=VmrIDyYiJBA

  vec2 p1 = mod(p, sz)-hsz;
  vec2 p2 = mod(p - hsz*1.0, sz)-hsz;
  vec2 p3 = dot(p1, p1) < dot(p2, p2) ? p1 : p2;
  vec2 n = p3 - p;
  p = p3;

  return n;
}

float circle(vec2 p, float r) {
  return length(p) - r;
}

float box(vec2 p, vec2 b) {
  vec2 d = abs(p)-b;
  return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

float unevenCapsule(vec2 p, float r1, float r2, float h) {
  p.x = abs(p.x);
  float b = (r1-r2)/h;
  float a = sqrt(1.0-b*b);
  float k = dot(p,vec2(-b,a));
  if( k < 0.0 ) return length(p) - r1;
  if( k > a*h ) return length(p-vec2(0.0,h)) - r2;
  return dot(p, vec2(a,b) ) - r1;
}

float cogwheel(vec2 p, float innerRadius, float outerRadius, float cogs, float holes) {
  float cogWidth  = 0.25*innerRadius*TAU/cogs;

  float d0 = circle(p, innerRadius);

  vec2 icp = p;
  modPolar(icp, holes);
  icp -= vec2(innerRadius*0.55, 0.0);
  float d1 = circle(icp, innerRadius*0.25);

  vec2 cp = p;
  modPolar(cp, cogs);
  cp -= vec2(innerRadius, 0.0);
  float d2 = unevenCapsule(cp.yx, cogWidth, cogWidth*0.75, (outerRadius-innerRadius));

  float d3 = circle(p, innerRadius*0.20);

  float d = 1E6;
  d = min(d, d0);
  d = pmin(d, d2, 0.5*cogWidth);
  d = min(d, d2);
  d = max(d, -d1);
  d = max(d, -d3);

  return d;
}

float ccell1(vec2 p, float r) {
  float d = 1E6;
  const float bigCount = 60.0;

  vec2 cp0 = p;
  rot(cp0, -TIME * GearSpeed *TAU/bigCount);
  float d0 = cogwheel(cp0, 0.36, 0.38, bigCount, 5.0);

  vec2 cp1 = p;
  float nm = modPolar(cp1, 6.0);

  cp1 -= vec2(0.5, 0.0);
  rot(cp1, 0.2+TAU*nm/2.0 + TIME * GearSpeed *TAU/smallCount);
  float d1 = cogwheel(cp1, 0.11, 0.125, smallCount, 5.0);

  d = min(d, d0);
  d = min(d, d1);
  return d;
}

float ccell2(vec2 p, float r) {
  float d = 1E6;
  vec2 cp0 = p;
  float nm = modPolar(cp0, 6.0);
  vec2 cp1 = cp0;
  const float off = 0.275;
  const float count = smallCount + 2.0;
  cp0 -= vec2(off, 0.0);
  rot(cp0, 0.+TAU*nm/2.0 - TIME * GearSpeed *TAU/count);
  float d0 = cogwheel(cp0, 0.09, 0.105, count, 5.0);


  cp1 -= vec2(0.5, 0.0);
  rot(cp1, 0.2+TAU*nm/2.0 + TIME * GearSpeed *TAU/smallCount);
  float d1 = cogwheel(cp1, 0.11, 0.125, smallCount, 5.0);

  float l = length(p);
  float d2 = l - (off+0.055);
  float d3 = d2 + 0.020;

  vec2 tp0 = p;
  modPolar(tp0, 60.0);
  tp0.x -= off;
  float d4 = box(tp0, vec2(0.0125, 0.005));

  float ctime = -(TIME * ClockSpeed *0.05 + r)*TAU;

  vec2 tp1 = p;
  rot(tp1, ctime*12.0);
  tp1.x -= 0.13;
  float d5 = box(tp1, vec2(0.125, 0.005));

  vec2 tp2 = p;
  rot(tp2, ctime);
  tp2.x -= 0.13*0.5;
  float d6 = box(tp2, vec2(0.125*0.5, 0.0075));

  float d7 = l - 0.025;
  float d8 = l - 0.0125;

  d = min(d, d0);
  d = min(d, d1);
  d = min(d, d2);
  d = max(d, -d3);
  d = min(d, d4);
  d = min(d, d5);
  d = min(d, d6);
  d = min(d, d7);
  d = max(d, -d8);

  return d;
}

float df(vec2 p, float scale, inout vec2 nn) {
  p /= scale;
  nn = hextile(p);
  nn = round(nn);
  float r = hash(nn);

  float d;

  if (r < 0.5) {
    d = ccell1(p, r);
  } else {
    d = ccell2(p, r);
  }

  return d*scale;
}

vec3 postProcess(vec3 col, vec2 q)  {
  //col = saturate(col);
  col=pow(clamp(col,0.0,1.0),vec3(0.75));
  col=col*0.6+0.4*col*col*(3.0-2.0*col);  // contrast
  col=mix(col, vec3(dot(col, vec3(0.33))), -0.4);  // satuation
  col*=0.5+0.5*pow(19.0*q.x*q.y*(1.0-q.x)*(1.0-q.y),0.7);  // vigneting
  return col;
}

void fragment() {
  vec2 q = FRAGCOORD.xy/(1.0 / SCREEN_PIXEL_SIZE).xy;
  vec2 p = -1. + 2. * q;
  p.x *= (1.0 / SCREEN_PIXEL_SIZE).x/(1.0 / SCREEN_PIXEL_SIZE).y;
  float tm = 0.1 + TIME * zoomSpeed;
  p += vec2(cos(tm), sin(tm*sqrt(0.5)));
  float z = mix(0.5, base_zoom, pcos(tm*sqrt(0.3)));
  float aa = 4.0 / (1.0 / SCREEN_PIXEL_SIZE).y;

  vec2 nn = vec2(0.0);
  float d = df(p, z, nn);

  vec3 col = back_color.rgb;
  vec3 baseCol = gears_color.rgb;
  vec4 logoCol = vec4(baseCol, 1.0)*smoothstep(-aa, 0.0, -d);
  col = mix(col, logoCol.xyz, pow(logoCol.w, 8.0));
  col += 0.4*pow(abs(sin(20.0*d)), 0.6);

  col = postProcess(col, q);

  COLOR.rgb = vec3(col);
  COLOR.a = texture(TEXTURE, UV).a;
}