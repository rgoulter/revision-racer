// adapted from http://gamedev.stackexchange.com/questions/11095/opengl-es-2-0-point-sprites-size

uniform mat4 uModelViewProjectionMatrix;
uniform vec3 uBackgroundColor;
uniform float uAlpha;

attribute vec3 aPosition;
attribute float aIntensity;
attribute float aBrightness;
attribute float aThickness;

varying lowp vec4 vColor;

void main() {
    vec4 position = uModelViewProjectionMatrix * vec4(aPosition.xyz, 1.);
    
    vColor = vec4(aBrightness, aBrightness, 0, uAlpha);
    
    vColor = (0.7 + 0.3 * aIntensity) * vColor +
             (1.0 - uAlpha) * vec4(uBackgroundColor, 1);
    vColor.a = uAlpha;
    
    gl_PointSize = aThickness;
    gl_Position =  position;
}