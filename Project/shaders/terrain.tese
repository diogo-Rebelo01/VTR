#version 410

layout(triangles, fractional_odd_spacing, ccw) in;

uniform	mat4 m_pvm, m_view;
uniform	mat3 m_normal;
uniform vec4 l_dir;
uniform float amplitude, scale, frequencia, first_level, second_level, third_level, redistribuicao;
uniform int num_octaves;
uniform vec4 dirt, grass, snow, sand;

//in vec2 texCoordTC[];
in vec4 posTC[];

int adjust = 100;

out Data {
    vec3 normal;
	vec3 l_dir;
    vec4 colorV;
} DataOut;

vec4 biome(float f){
    vec4 color;
    if(f > (third_level * scale) + adjust){
        color = snow;
    }
    else if(f <= (third_level * scale) + adjust && f > (second_level * scale) + adjust){
        color = grass;
    }
    else if(f <= (second_level * scale) + adjust && f > (first_level * scale) + adjust){
        color = dirt;
    }
    else {
        color = sand;
    }
    return color;
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
        height = - height;
        height = pow(height,redistribuicao);
        height = - height;
    }
    height *= amplitude;
    height += adjust;
    return height;
}


void main() {

	float u = gl_TessCoord.x;
	float v = gl_TessCoord.y;
	float w = gl_TessCoord.z;

	// compute point as weighted average of triangle vertices
	vec4 P = vec4( posTC[0] * u
				 + posTC[1] * v
				 + posTC[2] * w);;

	float offset = 16/frequencia;
	float scaleuv = 0.001;
	vec2 uv =  scaleuv * P.xz;
	vec2 uv1 = uv - scaleuv * vec2(0, offset);
	vec2 uv2 = uv + scaleuv * vec2(0, offset);
	vec2 uv3 = uv - scaleuv * vec2(offset, 0);
	vec2 uv4 = uv + scaleuv * vec2(offset, 0);

    float f  = elevation(uv);
    float f1 = elevation(uv1);
    float f2 = elevation(uv2);
    float f3 = elevation(uv3);
    float f4 = elevation(uv4);

    vec4 pos = vec4(P.x, f, P.z, 1);
    vec4 pos1 = vec4(P.x, f1, P.z-offset, 1);
    vec4 pos2 = vec4(P.x, f2, P.z+offset, 1);
    vec4 pos3 = vec4(P.x-offset, f3, P.z, 1);
    vec4 pos4 = vec4(P.x+offset, f4, P.z, 1);

	// Pass-through the texture coordinates
	//DataOut.texCoord1 = texCoord * tex;

	// Pass-through the normal and light direction
	DataOut.normal = normalize(m_normal * normalize(cross(vec3(pos2-pos1), vec3(pos4-pos3))));
	DataOut.l_dir = normalize(vec3(m_view * -l_dir));
    DataOut.colorV = biome(f);
	// transform the vertex coordinates
	gl_Position = m_pvm * pos;
}

