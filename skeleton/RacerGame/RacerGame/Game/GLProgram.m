// Adapted from http://iphonedevelopment.blogspot.sg/2010/11/opengl-es-20-for-ios-chapter-4.html
// Alternatively, https://github.com/jlamarche/iOS-OpenGLES-Stuff/blob/master/Simple%20OpenGL%20ES%202.0%20Example/Classes/GLProgram.m

#import "GLProgram.h"

// for the ATTRIB enum.
#import "BOStarCluster.h"


GLint uniforms[NUM_UNIFORMS];



#pragma mark Function Pointer Definitions

typedef void (*GLInfoFunction)(GLuint program, GLenum pname, GLint* params);
typedef void (*GLLogFunction) (GLuint program, GLsizei bufsize, GLsizei* length, GLchar* infolog);


#pragma mark -
#pragma mark Private Extension Method Declaration



@interface GLProgram()
/*{ // OLD
    NSMutableArray  *attributes;
    NSMutableArray  *uniforms;
    GLuint          program,
    vertShader,
    fragShader;
}*/

@property GLuint program;

- (BOOL)compileShader:(GLuint *)shader
                 type:(GLenum)type
                 file:(NSString *)file;

- (NSString *)logForOpenGLObject:(GLuint)object
                    infoCallback:(GLInfoFunction)infoFunc
                         logFunc:(GLLogFunction)logFunc;
@end



#pragma mark -



@implementation GLProgram

- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename
            fragmentShaderFilename:(NSString *)fShaderFilename
{
    self = [super init];
    
    if (self) {
        [self loadShaderWithVertexShaderFilename:vShaderFilename
                          fragmentShaderFilename:fShaderFilename];
    }
    
    return self;
}

- (BOOL)loadShaderWithVertexShaderFilename:(NSString *)vShaderFilename
                   fragmentShaderFilename:(NSString *)fShaderFilename
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:vShaderFilename ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:fShaderFilename ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex and fragment shaders to program.
    glAttachShader(_program, vertShader);
    glAttachShader(_program, fragShader);
    
    // Override bindAttributes in child classes
    [self bindAttributes];
    
    // Link program.
    if (![self link]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}








// NEW
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}





#pragma mark -

/*
- (void)addAttribute:(NSString *)attributeName
{
    if (![attributes containsObject:attributeName]) {
        [attributes addObject:attributeName];
        glBindAttribLocation(program,
                             (unsigned int)[attributes indexOfObject:attributeName],
                             [attributeName UTF8String]);
    }
}

- (GLuint)attributeIndex:(NSString *)attributeName
{
    return (GLuint)[attributes indexOfObject:attributeName];
}
*/
- (GLuint)uniformIndex:(NSString *)uniformName
{
    return glGetUniformLocation(_program, [uniformName UTF8String]);
}

- (void)bindAttributes
{
}

- (void)useDefaultUniformValues
{
}

#pragma mark -

- (BOOL)link
{
    GLint status;
    glLinkProgram(_program);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &logLength);
    
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(_program, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(_program, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (void)use
{
    glUseProgram(_program);
}

#pragma mark -

// OLD
- (NSString *)logForOpenGLObject:(GLuint)object
                    infoCallback:(GLInfoFunction)infoFunc
                         logFunc:(GLLogFunction)logFunc
{
    GLint logLength = 0, charsWritten = 0;
    
    infoFunc(object, GL_INFO_LOG_LENGTH, &logLength);
    
    if (logLength < 1) {
        return nil;
    }
    
    char *logBytes = malloc(logLength);
    logFunc(object, logLength, &charsWritten, logBytes);
    
    NSString *log = [[NSString alloc] initWithBytes:logBytes
                                              length:logLength
                                           encoding:NSUTF8StringEncoding];
    
    free(logBytes);
    
    return log;
}

- (NSString *)programLog
{
    return [self logForOpenGLObject:_program
                       infoCallback:(GLInfoFunction)&glGetProgramiv 
                            logFunc:(GLLogFunction)&glGetProgramInfoLog];
}

#pragma mark -

- (void)dealloc
{
    if (_program) {
        glDeleteProgram(_program);
    }
}

@end



@implementation MainGLProgram

- (id)init
{
    self = [super initWithVertexShaderFilename:@"shader"
                        fragmentShaderFilename:@"shader"];
    
    return self;
}

- (void)bindAttributes
{
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(self.program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(self.program, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(self.program, GLKVertexAttribColor, "color");
}

- (void)useDefaultUniformValues
{
    glUniform1i([self uniformIndex:@"isOutline"], 0);
    glUniform1f([self uniformIndex:@"alpha"], 1);
}

@end



@implementation StarClusterGLProgram

- (id)init
{
    self = [super initWithVertexShaderFilename:@"starcluster"
                        fragmentShaderFilename:@"starcluster"];
    
    return self;
}

- (void)bindAttributes
{
    NSLog(@"StarCluster bindAttributes::A");
    glBindAttribLocation(self.program, ATTRIB_STAR_VERTEX, "aPosition");
    glBindAttribLocation(self.program, ATTRIB_STAR_INTENSITY, "aIntensity");
    glBindAttribLocation(self.program, ATTRIB_STAR_BRIGHTNESS, "aBrightness");
    glBindAttribLocation(self.program, ATTRIB_STAR_THICKNESS, "aThickness");
    NSLog(@"StarCluster bindAttributes::B");
}

@end
