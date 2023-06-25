#version 410

layout(triangles, fractional_odd_spacing, ccw) in;


uniform	mat4 m_pvm, m_view;
uniform	mat3 m_normal;
uniform vec4 l_dir;
uniform float amplitude, scale, scaleMoisture, scaleTex, frequencia, first_level, second_level, third_level, fourth_level, redistribuicao, seed, seedMoisure, offset;
uniform int num_octaves, use_moisture;
uniform vec4 SNOW, MOUNTAIN, TUNDRA, BADLANDS, MUD, DIRT, GRAVEL, BEACH, DESERT, GRASSLAND, FOREST;
in vec2 texCoordTC[];
in vec4 posTC[];

int adjust = 100;

out Data {
    vec3 normal;
	vec3 l_dir;
    vec4 colorV;
    vec2 tc;
    float e;
} DataOut;


float rand(vec2 n) { 
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float moistureNoise(vec2 p){
    p*=scaleMoisture;
    p+=seedMoisure;

	vec2 ip = floor(p);
	vec2 u = fract(p);
	u = u*u*(3.0-2.0*u);
	
	float res = mix(
		mix(rand(ip),rand(ip+vec2(1.0,0.0)),u.x),
		mix(rand(ip+vec2(0.0,1.0)),rand(ip+vec2(1.0,1.0)),u.x),u.y);
	return res;
}


vec4 biome_no_moisure(float e){
    float mixtc;
    //BEACH
    //DIRT
    //GRASSLAND
    //MOUNTAIN
    //SNOW
    if(e < (first_level*scale)) {
        if(e <= 0) mixtc = 1.0 - smoothstep(0,first_level*scale,0);
        else mixtc = 1.0 - smoothstep(0,first_level*scale,e);
        vec3 beach = BEACH.xyz;
        vec3 dirt = DIRT.xyz;
        return vec4(mix(dirt, beach, mixtc),1.0);
        }
    
    if(e > (fourth_level * scale) + adjust){
        return SNOW;
    }
    if(e > (third_level * scale) + adjust){
        float start = (third_level * scale) + adjust;
        float end = (fourth_level * scale) + adjust;
        mixtc = 1.0 - smoothstep(start,end,e);
        vec3 mountain = MOUNTAIN.xyz;
        vec3 snow = SNOW.xyz;
        return vec4(mix(snow, mountain, mixtc),1.0);
    }
    if(e > (second_level * scale) + adjust){
        float start = (second_level * scale) + adjust;
        float end = (third_level * scale) + adjust;
        mixtc = 1.0 - smoothstep(start,end,e);
        vec3 grassland = GRASSLAND.xyz;
        vec3 mountain = MOUNTAIN.xyz;
        return vec4(mix(mountain, grassland, mixtc),1.0);
    }
    //if (e < 100) = mixtc = 1.0 - smoothstep(100,second_level,100);
    float start = (first_level * scale) + adjust;
    float end = (second_level * scale) + adjust;
    mixtc = 1.0 - smoothstep(start,end,e);
    vec3 dirt = DIRT.xyz;
    vec3 grassland = GRASSLAND.xyz;
    return vec4(mix(grassland, dirt, mixtc),1.0);
}


vec4 biome_fourth_level(float m){
    if(m < 0) m = 0;
    if(m > 1) m = 1;
    float mixcolor;
    if (m < 0.2) {
        mixcolor = 1.0 - smoothstep(0.0,0.2,m);
        //BADLANDS >> MOUNTAIN
        return vec4(mix(MOUNTAIN.xyz, BADLANDS.xyz, mixcolor),1.0);
    }
    if (m < 0.3) {
        mixcolor = 1.0 - smoothstep(0.2,0.3,m);
        //MOUNTAIN >> TUNDRA
        return vec4(mix(TUNDRA.xyz, MOUNTAIN.xyz, mixcolor),1.0);
    }
    if (m < 0.5){
        mixcolor = 1.0 - smoothstep(0.3,0.5,m);
        //TUNDRA >> SNOW
        return vec4(mix(SNOW.xyz, TUNDRA.xyz, mixcolor),1.0);
    }
    return SNOW;
}


vec4 biome_first_level(float m){
    if(m < 0) m = 0;
    if(m > 1) m = 1;
    float mixcolor;

    if (m < 0.16) {
        mixcolor = 1.0 - smoothstep(0.0,0.16,m);
        //MUD >> BEACH
        return vec4(mix(BEACH.xyz, MUD.xyz, mixcolor),1.0);
    }
    if (m < 0.33) {
        mixcolor = 1.0 - smoothstep(0.16,0.33,m);
        //BEACH >> GRAVEL
        return vec4(mix(GRAVEL.xyz, BEACH.xyz, mixcolor),1.0);
    }
    if (m < 0.43){
        mixcolor = 1.0 - smoothstep(0.33,0.43,m);
        //GRAVEL >> DIRT
        return vec4(mix(DIRT.xyz, GRAVEL.xyz, mixcolor),1.0);
    }
    return DIRT;
}


vec4 biome_second_level(float m){
    if(m < 0) m = 0;
    if(m > 1) m = 1;
    float mixcolor;

    if (m < 0.25) {
        mixcolor = 1.0 - smoothstep(0.0,0.25,m);
        //DESERT >> FOREST
        return vec4(mix(FOREST.xyz, DESERT.xyz, mixcolor),1.0);
    }
    if (m < 0.55) {
        mixcolor = 1.0 - smoothstep(0.25,0.55,m);
        //FOREST >> GRASSLAND
        return vec4(mix(GRASSLAND.xyz, FOREST.xyz, mixcolor),1.0);
    }
    return GRASSLAND;
}

vec4 biome_third_level(float m){
    if(m < 0.0) m = 0.0;
    if(m > 1.0) m = 1.0;
    float mixcolor;

    if (m < 0.1) {
        mixcolor = 1.0 - smoothstep(0.0,0.1,m);
        //GRASSLAND >> BADLANDS
        return vec4(mix(BADLANDS.xyz, GRASSLAND.xyz, mixcolor),1.0);
    }
    if (m < 0.25) {
        mixcolor = 1.0 - smoothstep(0.1,0.25,m);
        //BADLANDS >> MOUNTAIN
        return vec4(mix(MOUNTAIN.xyz, BADLANDS.xyz, mixcolor),1.0);
    }
    return MOUNTAIN;
}


vec4 biome(float e, float m){
    float mixcolor;
    if(e < first_level * scale) {
        if(e <= 0) mixcolor = 1.0 - smoothstep(0,first_level*scale,0);
        else mixcolor = 1.0 - smoothstep(0,first_level*scale,e);
        vec3 beach = BEACH.xyz;
        vec3 first = biome_first_level(m).xyz;
        return vec4(mix(first, beach, mixcolor),1.0);
    }
    
    if(e > (fourth_level * scale) + adjust){
        return biome_fourth_level(m);
    }
    if(e > (third_level * scale) + adjust){
        float start = (third_level * scale) + adjust;
        float end = (fourth_level * scale) + adjust;
        mixcolor = 1.0 - smoothstep(start,end,e);
        vec3 third = biome_third_level(m).xyz;
        vec3 fourth = biome_fourth_level(m).xyz;
        return vec4(mix(fourth, third, mixcolor),1.0);
    }
    if(e > (second_level * scale) + adjust){
        float start = (second_level * scale) + adjust;
        float end = (third_level * scale) + adjust;
        mixcolor = 1.0 - smoothstep(start,end,e);
        vec3 second = biome_second_level(m).xyz;
        vec3 third = biome_third_level(m).xyz;
        return vec4(mix(third, second, mixcolor),1.0);

    }
    float start = (first_level * scale) + adjust;
    float end = (second_level * scale) + adjust;
    mixcolor = 1.0 - smoothstep(start,end,e);
    vec3 first = biome_first_level(m).xyz;
    vec3 second = biome_second_level(m).xyz;
    return vec4(mix(second,first,mixcolor),1.0);
    //return biome_first_level(m);
}

vec2 grad( ivec2 z )  // replace this anything that returns a random vector
{
    // 2D to 1D  (feel free to replace by some other)
    int n = z.x+z.y*11111;

    // Hugo Elias hash (feel free to replace by another one)
    n = (n<<13)^n;
    n = (n*(n*n*15731+789221)+1376312589)>>16;

#if 0

    // simple random vectors
    return vec2(cos(float(n)),sin(float(n)));
    
#else

    // Perlin style vectors
    n &= 7;
    vec2 gr = vec2(n&1,n>>1)*2.0-1.0;
    return ( n>=6 ) ? vec2(0.0,gr.x) : 
           ( n>=4 ) ? vec2(gr.x,0.0) :
                              gr;
#endif                              
}

float noise( in vec2 p )
{
    p+= seed;

    ivec2 i = ivec2(floor( p ));
     vec2 f =       fract( p );
	
	vec2 u = f*f*(3.0-2.0*f); // feel free to replace by a quintic smoothstep instead

    return mix( mix( dot( grad( i+ivec2(0,0) ), f-vec2(0.0,0.0) ), 
                     dot( grad( i+ivec2(1,0) ), f-vec2(1.0,0.0) ), u.x),
                mix( dot( grad( i+ivec2(0,1) ), f-vec2(0.0,1.0) ), 
                     dot( grad( i+ivec2(1,1) ), f-vec2(1.0,1.0) ), u.x), u.y);
}

float elevation( in vec2 uv ) {
    float height = 0.0;
    float aux = 1.0;
    float auxT = 0.0;
    float freq = frequencia;
    for(int i = 0; i < num_octaves; i++){
        auxT += aux;
        height += aux * noise(freq * uv);
        freq *= 2.0;
        aux /= 2.0;
    }
    height /= auxT;
    if(height > 0.0) height = pow(height,redistribuicao);
    else{
        height = -height;
        height = pow(height,redistribuicao);
        height = -height;
    }
    height *= amplitude;
    height += adjust;
    return height;
}

float moisture(in vec2 uv) {
    float moisture = 0.0;
    float aux = 1.0;
    float auxT = 0.0;
    float freq = frequencia;
    for(int i = 0; i < num_octaves; i++){
        auxT += aux;
        moisture += aux * moistureNoise(freq * uv);
        freq *= 2.0;
        aux /= 2.0;
    }
    moisture /= auxT;
    return pow(moisture,redistribuicao);
}

void main() {

	float u = gl_TessCoord.x;
	float v = gl_TessCoord.y;
	float w = gl_TessCoord.z;

	// compute point as weighted average of triangle vertices
	vec4 P = vec4( posTC[0] * u
				 + posTC[1] * v
				 + posTC[2] * w);
    
    vec2 texCoord = vec2( texCoordTC[0] * u
						+ texCoordTC[1] * v
						+ texCoordTC[2] * w);

	float os = offset/frequencia;
	float scaleuv = 0.001;
	vec2 uv =  scaleuv * P.xz;
	vec2 uv1 = uv - scaleuv * vec2(0, os);
	vec2 uv2 = uv + scaleuv * vec2(0, os);
	vec2 uv3 = uv - scaleuv * vec2(os, 0);
	vec2 uv4 = uv + scaleuv * vec2(os, 0);


    float f  = elevation(uv);
    float f1 = elevation(uv1);
    float f2 = elevation(uv2);
    float f3 = elevation(uv3);
    float f4 = elevation(uv4);

    vec4 pos = vec4(P.x, f, P.z, 1);
    vec4 pos1 = vec4(P.x, f1, P.z-os, 1);
    vec4 pos2 = vec4(P.x, f2, P.z+os, 1);
    vec4 pos3 = vec4(P.x-os, f3, P.z, 1);
    vec4 pos4 = vec4(P.x+os, f4, P.z, 1);

	// Pass-through the texture coordinates
	//DataOut.texCoord1 = texCoord * tex;

	// Pass-through the normal and light direction
    DataOut.tc = texCoord * scaleTex;
	DataOut.normal = normalize(m_normal * normalize(cross(vec3(pos2-pos1), vec3(pos4-pos3))));
	DataOut.l_dir = normalize(vec3(m_view * -l_dir));
    DataOut.e = f;
    float m = moisture(uv);

    if(use_moisture == 1) DataOut.colorV = biome(f,m);
    else DataOut.colorV = biome_no_moisure(f);

	// transform the vertex coordinates
	gl_Position = m_pvm * pos;

    
}

