#version 410

uniform	mat3 m_normal;
uniform sampler2D texDIRT, texGRASS, texSNOW, texSAND, texROCK;
uniform int use_textures;
uniform float scale, first_level, second_level, third_level, fourth_level;

in Data {
	vec3 normal;
	vec3 l_dir;
	vec4 colorV;
	vec2 tc;
	float e;
} DataIn;

out vec4 color;

int adjust = 100;

vec4 biome_textures(float e, vec2 tc){
    float mixtc;
    
    if(e < (first_level*scale)) {
        if(e <= 0) mixtc = 1.0 - smoothstep(0,first_level*scale,0);
        else mixtc = 1.0 - smoothstep(0,first_level*scale,e);
        vec3 sand = texture(texSAND,tc).xyz;
        vec3 dirt = texture(texDIRT,tc).xyz;
        return vec4(mix(dirt, sand, mixtc),1.0);
        }
    
    if(e > (fourth_level * scale) + adjust){
        return texture(texSNOW,tc);
    }
    if(e > (third_level * scale) + adjust){
        float start = (third_level * scale) + adjust;
        float end = (fourth_level * scale) + adjust;
        mixtc = 1.0 - smoothstep(start,end,e);
        vec3 rock = texture(texROCK,tc).xyz;
        vec3 snow = texture(texSNOW,tc).xyz;
        return vec4(mix(snow, rock, mixtc),1.0);
    }
    if(e > (second_level * scale) + adjust){
        float start = (second_level * scale) + adjust;
        float end = (third_level * scale) + adjust;
        mixtc = 1.0 - smoothstep(start,end,e);
        vec3 grass = texture(texGRASS,tc).xyz;
        vec3 rock = texture(texROCK,tc).xyz;
        return vec4(mix(rock, grass, mixtc),1.0);
    }
    //if (e < 100) = mixtc = 1.0 - smoothstep(100,second_level,100);
    float start = (first_level * scale) + adjust;
    float end = (second_level * scale) + adjust;
    mixtc = 1.0 - smoothstep(start,end,e);
    vec3 dirt = texture(texDIRT,tc).xyz;
    vec3 grass = texture(texGRASS,tc).xyz;
    return vec4(mix(grass, dirt, mixtc),1.0);
}

void main(void) {
    float intensity, inclination;
    intensity = max(0.0, dot(normalize(DataIn.normal), normalize(DataIn.l_dir)));
    inclination = 0.6 * max(0.0, dot(normalize(DataIn.normal), normalize(m_normal * vec3(0,1,0))));

	//outputF = intensity * diffuse + ambient;
    //vec4 texture = (1-inclination) * dirt + inclination * texture(texGrass, DataIn.texCoord1);
	//vec4 texture = mix(dirt, grass, inclination);
	vec4 texture;
	if(use_textures == 0) texture = DataIn.colorV;
	else texture = biome_textures(DataIn.e, DataIn.tc);
	color = clamp((intensity + 0.25) * texture, 0, 1);
	//color = clamp((intensity + 0.25) * vec4(1,1,1,1), 0, 1);

}