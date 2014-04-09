// Adapted from http://iphonedevelopment.blogspot.sg/2010/11/opengl-es-20-for-ios-chapter-4.html

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import <GLKit/GLKit.h>



// Uniform index.
enum uniform
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_ISOUTLINE_BOOL,
    NUM_UNIFORMS
};

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    ATTRIB_COLOR,
    NUM_ATTRIBUTES
};



@interface GLProgram : NSObject

- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename
            fragmentShaderFilename:(NSString *)fShaderFilename;

//- (void)addAttribute:(NSString *)attributeName;

//- (GLuint)attributeIndex:(NSString *)attributeName;

//- (GLuint)uniformIndex:(NSString *)uniformName;
- (GLuint)uniformIndex:(enum uniform)uniformName;

- (BOOL)link;

- (void)use;

- (NSString *)programLog;

@end
