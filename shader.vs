#version 330

/* in vec3 position;
in vec2 texCoords;
in vec3 normal;
in vec4 color;
in mat4 modelMatrix; */

layout (location = 0) in vec3 position;
layout (location = 1) in vec2 texCoords;
layout (location = 2) in vec3 normal;
layout (location = 3) in vec4 color;
layout (location = 4) in mat4 modelMatrix;

out vec3 WorldPosition;
out vec2 TexCoords;
out vec3 Normal;
out vec3 EnvironmentLight;

uniform mat4 ProjectionMatrix;
uniform mat4 ViewMatrix;
// uniform vec3 cameraPosition;

void main() {
	vec4 worldPos = modelMatrix * vec4(position, 1.0);
	vec4 worldNormal = modelMatrix * vec4(normal, 0.0);
	
	gl_Position = ProjectionMatrix * ViewMatrix * worldPos;
	// InstanceId = gl_InstanceID;
	
	TexCoords = texCoords
	
	WorldPosition = worldPos.xyz;
	Normal = worldNormal.xyz;
	
	vec3 sunDirection = normalize(vec3(-1.0, 5.0, 6.0));
	
	vec3 skyDirection = vec3(0.0, 0.0, 1.0);

	float sunIntensity = 2.6;
	float skyLightIntensity = 1.0;
	
	vec3 sunLightColor = vec3(252.0 / 255.0, 1.0, 165.0 / 255.0) * sunIntensity;
	
	vec3 skyColor = vec3(1.0, 1.0, 1.0) * skyLightIntensity;
	
	float dotNormal = dot(Normal, sunDirection);
	float dotNormalSky = dot(Normal, skyDirection);
	
	// vec3 sunLight = sunLightColor * max(dotNormal, 0.0);
	vec3 sunLight = sunLightColor * (max(dotNormal, 0.0) * 0.9 + (dotNormal * 0.5 + 0.5) * 0.1);
	vec3 skyLight = skyColor * (max(dotNormalSky, 0.0) * 0.5 + 0.5);
	EnvironmentLight = sunLight + skyLight;
}
