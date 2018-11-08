//
//  OpenGLView.m
//  Tutorial01
//
//  Created by waqu on 2017/8/14.
//  Copyright © 2017年 com.waqu. All rights reserved.
//

#import "OpenGLView.h"
#import "GLUtils.h"
#import "JpegUtil.h"

#import "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp"
#include "glm/gtc/type_ptr.hpp"

// 使用匿名 category 来声明私有成员
@interface OpenGLView()

- (void)setupLayer;
- (void)setupContext;
- (void)setupRenderBuffer;
- (void)destoryRenderAndFrameBuffer;
- (void)render;

@end

@implementation OpenGLView

+ (Class)layerClass {
    // 只有 [CAEAGLLayer class] 类型的 layer 才支持在其上描绘 OpenGL 内容。
    return [CAEAGLLayer class];
}

- (void)setupLayer
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    _eaglLayer.opaque = YES;
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext {
    // 指定 OpenGL 渲染 API 的版本，在这里我们使用 OpenGL ES 2.0 
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    // 设置为当前上下文
    if (![EAGLContext setCurrentContext:_context]) {
        _context = nil;

        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    // 设置为当前 renderbuffer
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    // 为 color renderbuffer 分配存储空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];    
}

- (void)setupFrameBuffer {    
    glGenFramebuffers(1, &_frameBuffer);
    // 设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, 
                              GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)destoryRenderAndFrameBuffer
{
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
}

- (void)render {
    glClearColor(1.0, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glLineWidth(2.0);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    [self setupVBO];
    [self setupTexure];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glUniform1i(glGetUniformLocation(_program, "image"), 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _textureImg2);
    glUniform1i(glGetUniformLocation(_program, "image2"), 1);
    
    // Method one and two
//    glDrawArrays(GL_TRIANGLES, 0, _vertCount);
    
    // Method three
    glDrawArrays(GL_TRIANGLE_STRIP, 0, _vertCount);

    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];        
        [self setupContext];
        [self setupGLProgram];
    }
    return self;
}

- (void)layoutSubviews {
    [EAGLContext setCurrentContext:_context];
    
    [self destoryRenderAndFrameBuffer];
    
    [self setupRenderBuffer];        
    [self setupFrameBuffer];    
    
    [self render];
}

- (void) setupGLProgram {
    NSString *vertFile = [[NSBundle mainBundle] pathForResource:@"Shader.vsh" ofType:nil];
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"Shader.fsh" ofType:nil];
    
    _program = createGLProgramFromFile(vertFile.UTF8String, fragFile.UTF8String);
    
    glUseProgram(_program);
}


- (void)setupVBO
{
    // method one
//    _vertCount = 6;
//    GLfloat vertices[] = {
//        0.5f,  0.5f, 0.0f, 1.0f, 0.0f,   // 右上
//        0.5f, -0.5f, 0.0f, 1.0f, 1.0f,   // 右下
//        -0.5f, -0.5f, 0.0f, 0.0f, 1.0f,  // 左下
//        -0.5f, -0.5f, 0.0f, 0.0f, 1.0f,  // 左下
//        -0.5f,  0.5f, 0.0f, 0.0f, 0.0f,  // 左上
//        0.5f,  0.5f, 0.0f, 1.0f, 0.0f,   // 右上
//    };
//    
//    // 创建VBO
//    _vbo = createVBO(GL_ARRAY_BUFFER, GL_STATIC_DRAW, sizeof(vertices), vertices);
//    
//    glEnableVertexAttribArray(glGetAttribLocation(_program, "position"));
//    glVertexAttribPointer(glGetAttribLocation(_program, "position"), 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL);
//    
//    glEnableVertexAttribArray(glGetAttribLocation(_program, "texcoord"));
//    glVertexAttribPointer(glGetAttribLocation(_program, "texcoord"), 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL+sizeof(GL_FLOAT)*3);
    ////////////////////////////////////
    
    
    
    //Method two
    // 顶点坐标按顺序 需要六个顶点坐标  glDrawArrays(GL_TRIANGLES, 0, _vertCount);
//    _vertCount = 6;
//    static GLfloat vertices[] = {
//        0.5f,  0.5f, 0.0f,   // 右上
//        0.5f, -0.5f, 0.0f,   // 右下
//        -0.5f, -0.5f, 0.0f,  // 左下
//        -0.5f, -0.5f, 0.0f,  // 左下
//        -0.5f,  0.5f, 0.0f,  // 左上
//        0.5f,  0.5f, 0.0f,   // 右上
//    };
//
//    static GLfloat vertices1[] = {
//        1.0f, 0.0f,   // 右上
//        1.0f, 1.0f,   // 右下
//        0.0f, 1.0f,  // 左下
//        0.0f, 1.0f,  // 左下
//        0.0f, 0.0f,  // 左上
//        1.0f, 0.0f,   // 右上
//    };


    

    // Method  three
    // 顶点坐标不是按顺序，按Z字形，可以是四个顶点坐标  glDrawArrays(GL_TRIANGLE_STRIP, 0, _vertCount);
    _vertCount = 4;
    static GLfloat vertices[] = {
        1.0f,  1.0f, 0.0f,   // 右上
        1.0f, -1.0f, 0.0f,   // 右下
        -1.0f,  1.0f, 0.0f,  // 左上
        -1.0f, -1.0f, 0.0f,  // 左下
    };

    // 图片的文理的坐标是左上角（0，0），右下角（1，1）
    static GLfloat vertices1[] = {
        1.0f, 0.0f,   // 右上
        1.0f, 1.0f,   // 右下
        0.0f, 0.0f,  // 左上
        0.0f, 1.0f,  // 左下
    };
    
    glEnableVertexAttribArray(glGetAttribLocation(_program, "position"));
    glVertexAttribPointer(glGetAttribLocation(_program, "position"), 3, GL_FLOAT, GL_FALSE, 0, vertices);
    
    glEnableVertexAttribArray(glGetAttribLocation(_program, "texcoord"));
    glVertexAttribPointer(glGetAttribLocation(_program, "texcoord"), 2, GL_FLOAT, GL_FALSE, 0, vertices1);
    
    // 译注：下面就是矩阵初始化的一个例子，如果使用的是0.9.9及以上版本
    // 下面这行代码就需要改为:
    // glm::mat4 trans = glm::mat4(1.0f)
    glm::mat4 trans;
    trans = glm::rotate(trans, glm::radians(90.0f), glm::vec3(0.0, 0.0, 1.0));
    trans = glm::scale(trans, glm::vec3(0.5, 0.5, 0.5));
    
    int transforLoc = glGetUniformLocation(_program, "transform");
    glUniformMatrix4fv(transforLoc, 1, GL_FALSE, glm::value_ptr(trans));
}

- (void)setupTexure
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"wood" ofType:@"jpg"];
    
    unsigned char *data;
    int size;
    int width;
    int height;
    
    // 加载纹理
    if (read_jpeg_file(path.UTF8String, &data, &size, &width, &height) < 0) {
        printf("%s\n", "decode fail");
    }
    
    // 创建纹理
    _texture = createTexture2D(GL_RGB, width, height, data);
    
    if (data) {
        free(data);
        data = NULL;
    }
    
    // image2
    path = [[NSBundle mainBundle] pathForResource:@"flower" ofType:@"jpg"];
    
    // 加载纹理
    if (read_jpeg_file(path.UTF8String, &data, &size, &width, &height) < 0) {
        printf("%s\n", "decode fail");
    }
    
    // 创建纹理
    _textureImg2 = createTexture2D(GL_RGB, width, height, data);
    
    if (data) {
        free(data);
        data = NULL;
    }
    
}

@end
