# Antialiased nearest sampling glsl

Implementation of antialiased nearest texture sampling in glsl shader language

The alorithm is implemented in `textureNearestAntialias`. Full code contains some more logic like lighting calculations. Decided to grab it whole without removing stuff, because I can be sure it will work.

 All logic related to nearest sampling with antialiasing represented by these lines of code in `fragment.glsl`:
```glsl
#version 330

#extension GL_OES_standard_derivatives : enable

in vec2 TexCoords;

/* ... */

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

void main() {
	// getting texture size
	vec2 texSize = textureSize(AlbedoTexture, 0);

	// sampling the texture
	vec4 albedoValue = textureNearestAntialias(AlbedoTexture, TexCoords, texSize);
}
```

## Notes
It uses `fwidth` glsl function to get texel density for each texture coord: U and V (As long as `texCoords` function argument will contain a vector that is calculated from texture coords that are passed from vertex shader). Also the reason why it requires `GL_OES_standard_derivatives` extension.

To make it work texture must have `nearest` sampling, algo relies on those calculations that will be made by graphics driver.

To get texture size you can use either `textureSize(AlbedoTexture, 0);` call, or pass it by uniform, or define it as a constant (least preferred method but can test it that way)
