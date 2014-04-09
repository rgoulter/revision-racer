// adapted from http://gamedev.stackexchange.com/questions/11095/opengl-es-2-0-point-sprites-size

uniform mat4 modelViewProjectionMatrix;
//uniform float uThickness;

attribute vec3 aPosition;
attribute float aIntensity;
attribute float aBrightness;

varying vec4 vColor;

void main() {
    vec4 position = modelViewProjectionMatrix * vec4(aPosition.xyz, 1.);
    
    vColor = vec4(0, 1, 1, aIntensity) * aBrightness;
    
    gl_PointSize = 1.0; //uThickness;
    gl_Position =  position;
}