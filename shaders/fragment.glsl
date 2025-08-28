#define GLSLIFY 1
//
// Description : Array and textureless GLSL 2D/3D/4D simplex
//               noise functions.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
     return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

float snoise(vec3 v)
  {
  const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
  const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

// First corner
  vec3 i  = floor(v + dot(v, C.yyy) );
  vec3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min( g.xyz, l.zxy );
  vec3 i2 = max( g.xyz, l.zxy );

  //   x0 = x0 - 0.0 + 0.0 * C.xxx;
  //   x1 = x0 - i1  + 1.0 * C.xxx;
  //   x2 = x0 - i2  + 2.0 * C.xxx;
  //   x3 = x0 - 1.0 + 3.0 * C.xxx;
  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
  vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

// Permutations
  i = mod289(i);
  vec4 p = permute( permute( permute(
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 ))
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

// Gradients: 7x7 points over a square, mapped onto an octahedron.
// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
  float n_ = 0.142857142857; // 1.0/7.0
  vec3  ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4( x.xy, y.xy );
  vec4 b1 = vec4( x.zw, y.zw );

  //vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
  //vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
  vec4 s0 = floor(b0)*2.0 + 1.0;
  vec4 s1 = floor(b1)*2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  vec3 p0 = vec3(a0.xy,h.x);
  vec3 p1 = vec3(a0.zw,h.y);
  vec3 p2 = vec3(a1.xy,h.z);
  vec3 p3 = vec3(a1.zw,h.w);

//Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1),
                                dot(p2,x2), dot(p3,x3) ) );
  }

varying vec2 vUv;

uniform float u_time;
uniform vec2 uResolution;
uniform samplerCube uCubemap;
uniform sampler2D uBlueNoiseTexture;
uniform int uFrame;
uniform vec3 uCameraPosition;
uniform vec3 uCameraTarget;

vec3 sampleCubemap(vec3 direction) {
    return textureCube(uCubemap, direction).rgb;
}

mat3 rotateZ(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat3(
        c, -s, 0.0,
        s, c, 0.0,
        0.0, 0.0, 1.0
    );
}

float sdSphere(vec3 p, float radius) {
    return length(p) - radius;
}

vec3 getBlackholePos(float time) {
    float amplitude = 1.0;
    float frequency = 0.3;
    return vec3(
        sin(time * frequency) * amplitude,
        0.0,
        0.0
    );
}

vec4 getDist(vec3 p) {
    vec3 blackholePos = getBlackholePos(u_time);
    
    // float orbitRadius = 6.0;
    // float orbitSpeed = 0.75;
    // vec3 spherePos = vec3(
    //     cos(u_time * orbitSpeed) * orbitRadius,
    //     0.0,
    //     sin(u_time * orbitSpeed) * orbitRadius
    // );
    
    vec4 blackhole = vec4(vec3(0.0, 0.0, 0.0), sdSphere(p - blackholePos, 2.5));
 
    return blackhole;
}

float sdCylinder(vec3 p, vec3 cylinder) {
    float r1 = cylinder.x;
    float r2 = cylinder.y;
    float h  = cylinder.z;

    float radialDist = length(p.xz);

    float distOuter = radialDist - r2;
    float distInner = r1 - radialDist;
    float distY = abs(p.y) - h * 0.5;

    vec2 d2 = vec2(max(distOuter, distInner), distY);
    return min(max(d2.x, d2.y), 0.0) + length(max(d2, 0.0));
}

mat3 getCam(vec3 ro, vec3 lookAt) {
    vec3 camF = normalize(vec3(lookAt - ro));
    vec3 camR = normalize(cross(vec3(0, 1, 0), camF));
    vec3 camU = cross(camF, camR);
    return mat3(camR, camU, camF);
}

const float OUTER_FADE_STARTS = 0.0;
const float OUTER_FADE_ENDS = 8.0;
const float INNER_FADE_RADIUS = 2.78;  
const float INNER_RADIUS = 2.25;
const float OUTER_RADIUS = 9.0;
const float HEIGHT = 0.9;

const int MAX_STEPS = 100;
const float MAX_DIST = 50.0;
const float SURFACE_DIST = 0.001;
const float STEP_SIZE = 0.2;
const float ABSORPTION_COEFFICIENT = 0.5;
const float BRIGHTNESS = 0.7;
const float LIGHT_INTENSITY = 7.0;
const float MASS = 2.5;

float computeDensity(vec3 position) {
    vec3 blackholePos = getBlackholePos(u_time);
    float speed = u_time * 0.80;

    mat3 diskRotation = rotateZ(0.10); 
    vec3 rotatedPos = diskRotation * (position - blackholePos);
    
    float ring = sdCylinder(rotatedPos, vec3(INNER_RADIUS, OUTER_RADIUS, HEIGHT));
    
    vec3 local = rotatedPos;
    
    
    if (ring > 0.0) return 0.0;
    
    float ringCenter = (INNER_RADIUS + OUTER_RADIUS) * 0.5;
    float distFromRingCenter = abs(length(local.xz) - ringCenter);
    float ringWidth = OUTER_RADIUS - INNER_RADIUS;
    

    float normalizedDist = distFromRingCenter / (ringWidth * 0.5);

    vec2 xz = local.xz;
    float radius = length(xz) + 0.001;
    float theta = atan(xz.y, xz.x);

    float orbitalSpeed = -25.0 / pow(radius, 0.5);
    float startRotation = -50.0 / pow(radius, 0.5);
    float angleOffset = startRotation + theta + orbitalSpeed;

    float normalizedRadius = (radius) / (INNER_RADIUS) * 20.0;
    
    vec2 polar = vec2(normalizedRadius, (local.y + HEIGHT * 0.5) / HEIGHT);

    float u = cos(angleOffset - speed) * polar.x * 0.5 + 0.5;
    float w = sin(angleOffset - speed) * polar.x * 0.5 + 0.5;
    vec3 diskPolarPos = vec3(u, polar.y, w);

    // Use FBM??
    float noise = clamp(snoise(diskPolarPos * 3.0) * 3.5, 0.25, 1.25);

    float radialDensity = 1.0 / (radius * 0.3 + 0.4);
    float baseDensity = 6.0;

    float innerFade = smoothstep(
            INNER_FADE_RADIUS, 
            INNER_FADE_RADIUS + 1.0, // fade width, 
            radius
        );

    float outerFade = 1.0 - smoothstep(OUTER_FADE_STARTS, OUTER_FADE_ENDS, radius);

    float radialFade = innerFade * outerFade;

    return clamp(-ring * radialFade * noise * radialDensity * baseDensity, 0.0, 0.5); // Higher max density for more opacity
}

float getTransmittanceAtPosition(vec3 position, vec3 lightDirection) {
    vec3 pos = position - lightDirection;
    float currentDensity = computeDensity(pos);
    
    float transmittance = exp(-pow(currentDensity, ABSORPTION_COEFFICIENT));
    return transmittance;
}

vec4 raymarch(vec3 ro, inout vec3 direction) {
    vec4 result = vec4(0.0, 0.0, 0.0, MAX_DIST);

    vec3 position = ro;

    vec3 baseColor = vec3(0.0);
    vec3 cloudColor = vec3(0.0);
    float baseTransmittance = 1.0;
    bool hitSphere = false;
    float sphereDistance = MAX_DIST;

    float blueNoise = texture2D(uBlueNoiseTexture, gl_FragCoord.xy / 1024.0).r;
    float offset = fract(blueNoise + float(uFrame%32) / sqrt(0.5));
    float stepSize = STEP_SIZE * offset;

    for(int i = 0; i < MAX_STEPS; i++) {
        float rayDistance = float(i) * stepSize;
       
        
        vec4 distance = getDist(position);
        float sphereDistance = distance.w;
        
        vec3 blackholePos = getBlackholePos(u_time);
        vec3 toBlackhole = position - blackholePos;
        float distanceToBlackhole = length(toBlackhole);
        
        if(rayDistance > MAX_DIST) {
            break;
        }

         float density = computeDensity(position + (direction * stepSize));

            if (density > 0.001) { // Lower threshold to include more density
                vec3 lightPos = normalize(getBlackholePos(u_time)) - position;
                float transmittance = getTransmittanceAtPosition(position, lightPos);

               
                float softDensity = pow(density, BRIGHTNESS);
                float scattering = softDensity * STEP_SIZE;
                float squaredDistance = dot(getBlackholePos(u_time) - position, getBlackholePos(u_time) - position);
                float attenuation = LIGHT_INTENSITY / (max(squaredDistance, 0.001) * 0.025);
               
                float ratioDistance = clamp((distanceToBlackhole - INNER_RADIUS) / (OUTER_RADIUS - INNER_RADIUS), 0.0, 1.0);
                vec3 hotColor = vec3(1.0, 1.0, 1.0) * 3.0;           
                vec3 coolColor = vec3(2.3, 0.7, 0.0) * 4.0;
    
                vec3 cloudTint = hotColor * (1.0 - ratioDistance) + coolColor * ratioDistance;
                cloudColor += baseTransmittance * softDensity  * cloudTint * attenuation * scattering;
                baseTransmittance *= exp(-pow(density, STEP_SIZE) * ABSORPTION_COEFFICIENT);

                if (baseTransmittance < 0.001) { 
                    break;
                }
            }

        vec3 gravitationalLensing = normalize(toBlackhole) * STEP_SIZE / pow(distanceToBlackhole, 2.2) * MASS;
        direction = normalize(direction - gravitationalLensing);

        position += direction * STEP_SIZE;
        
        if (sphereDistance < SURFACE_DIST) {
            // handle hitting black sphere
            result = vec4(distance.rgb + cloudColor.rgb, rayDistance);
            break;
        } 
        result = vec4(sampleCubemap(direction), 1.0) * 0.1 + vec4(cloudColor, rayDistance);
    }

    return result;
}

void main() {
    vec2 uv = vUv * 2.0 - 1.0;
    uv.x *= uResolution.x / uResolution.y;

    vec3 color = vec3(0.0);

    // Use camera uniforms instead of hardcoded values
    vec3 ro = uCameraPosition;
    vec3 lookAt = uCameraTarget;

    vec3 rd = getCam(ro, lookAt) * normalize(vec3(uv, 1.0));

    vec4 marchResult = raymarch(ro, rd);
    float d = marchResult.w;
    color = marchResult.rgb;

    color = pow(color, vec3(.4545));
    gl_FragColor = vec4(color, 1.0);
}