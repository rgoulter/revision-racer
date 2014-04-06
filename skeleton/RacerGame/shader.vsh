// Adapted from OpenGL Example

attribute vec4 position;
attribute vec3 normal;
attribute vec3 color;

varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

uniform bool isOutline;

void main()
{
    if (!isOutline) {
        vec3 eyeNormal = normalize(normalMatrix * normal);
        vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    
        float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
    
        colorVarying = vec4(color, 1) * nDotVP;
    } else {
        colorVarying = vec4(0, 0, 0, 1);
    }
    
    gl_Position = modelViewProjectionMatrix * position;
}