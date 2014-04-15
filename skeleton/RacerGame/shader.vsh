// Adapted from OpenGL Example

attribute vec4 position;
attribute vec3 normal;
attribute vec3 color;

varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

uniform bool isOutline;
uniform float alpha;
uniform vec3 backgroundColor;

void main()
{
    if (!isOutline) {
        vec3 eyeNormal = normalize(normalMatrix * normal);
        vec3 lightPosition = vec3(0.0, 0.0, 4.0);
    
        float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
    
        colorVarying = vec4(color, 1) * nDotVP * 0.5 + vec4(color, 1) * 0.5;
    } else {
        colorVarying = vec4(0, 0, 0, 1);
    }
    
    // For a nicer "fade-out" effect,
    // blend the color with the background based on the
    // somewhat mis-named "alpha" uniform.
    colorVarying = alpha * colorVarying + (1.0 - alpha) * vec4(backgroundColor, 1);
    
    gl_Position = modelViewProjectionMatrix * position;
}