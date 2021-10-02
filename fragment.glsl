#version 330

#extension GL_OES_standard_derivatives : enable

in vec3 WorldPosition;
in vec2 TexCoords;
in vec3 Normal;
in vec3 EnvironmentLight;

layout (location = 0) out vec4 FragColor;
layout (location = 1) out vec4 BrightColor;

uniform sampler2D AlbedoTexture;
uniform sampler2D EmissionTexture;

uniform vec3 CameraPosition;
// uniform vec2 TextureSize;

const float Eps = 1e-10;

vec4 textureNearestAntialias(sampler2D sampler, vec2 texCoords, vec2 texSize) {
	vec2 tx = texCoords * texSize;
	vec2 w = vec2(fwidth(tx.x), fwidth(tx.y));
	vec2 q = step(1.0, w);
	vec2 threshold = clamp(w, Eps, 1.0);

	vec2 txMin = tx - 0.5 * threshold;
	vec2 txMax = tx + 0.5 * threshold;
	
	vec2 snapMin = mix((floor(txMin) + 0.5) / texSize, texCoords, q);
	vec2 snapMax = (floor(txMax) + 0.5) / texSize;
	
	vec4 c11 = texture(sampler, vec2( snapMin.x, snapMin.y ), -1); // -1 means don't use mip-maps (seems like)
	vec4 c21 = texture(sampler, vec2( snapMax.x, snapMin.y ), -1);
	vec4 c12 = texture(sampler, vec2( snapMin.x, snapMax.y ), -1);
	vec4 c22 = texture(sampler, vec2( snapMax.x, snapMax.y ), -1);
	
	vec2 f = mix(min(fract(txMax) / threshold, 1.0), vec2(0.0), q);
	
	vec4 tA = mix(c11, c21, f.x);
	vec4 tB = mix(c12, c22, f.x);
	return mix(tA, tB, f.y);
}

/* vec4 textureNearest(sampler2D sampler, vec2 texCoords, vec2 texSz) {
	vec2 texelSize = 1.0 / texSz;
	
	vec2 pixel = texCoords * texSz;
    
	vec2 snapPixel = floor(pixel) / texSz;
	return texture(sampler, snapPixel + texelSize * 0.5, -1);
	
//	return texture(sampler, texCoords);
} */

const vec3 greyscale = vec3(0.2126, 0.7152, 0.0722);

vec3 boostSaturation(vec3 color, float k) {
	return max((color - vec3(k)) / (1.0 - k), 0.0);
}

void main() {
	const float EmissionIntensity = 1.0;
	const float Exposure = 1.3;
	const float EmissionThreshold = 1.0;

	// vec2 texSize = vec2(16.0, 32.0);
	vec2 texSize = textureSize(AlbedoTexture, 0);
	
	vec4 albedoValue = textureNearestAntialias(AlbedoTexture, TexCoords, texSize);
	vec3 albedo = albedoValue.rgb;
	

	float emission = texture(EmissionTexture, TexCoords).r * EmissionIntensity;

	// degamma
	vec3 albedo2 = pow(albedo, vec3(2.2));
	
	albedo = pow(albedo, vec3(2.8));
	vec3 color = albedo * EnvironmentLight;
	color = vec3(1.0) - exp(-color * Exposure);
	vec3 outColor = color + albedo2 * emission;
	
	FragColor = vec4(outColor, albedoValue.a);

	float brightness = dot(outColor, greyscale);
	float w = max( mix(0.0, brightness, step(EmissionThreshold, brightness)), emission);
	vec3 z = boostSaturation(albedo2, 0.18) * w;
	
	BrightColor = vec4(z, 1.0);
}
