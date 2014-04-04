

void main( void )
{
	// Adapted from Phong Shader example
//	ecNormal         = normalize( gl_NormalMatrix * gl_Normal );
//	vec4 ecPosition4 = gl_ModelViewMatrix * gl_Vertex;
//	ecPosition       = vec3( ecPosition4 ) / ecPosition4.w;
	
	// Convert Trangent from Model Space to Eye Space.
//	vec4 ecTangent4  = gl_ModelViewMatrix * vec4( Tangent, 1 );
//	ecTangent        = vec3( ecTangent4 ) / ecTangent4.w;
	
	// Adapted from Lec 4 notes, slide 20
//	gl_TexCoord[0] = gl_MultiTexCoord0;
	gl_Position = ftransform();
}