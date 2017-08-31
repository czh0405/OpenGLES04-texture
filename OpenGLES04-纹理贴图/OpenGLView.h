//
//  OpenGLView.h
//  
//
//  Created by waqu on 2017/8/14.
//  Copyright © 2017年 com.waqu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

@interface OpenGLView : UIView {
    CAEAGLLayer*    _eaglLayer;
    EAGLContext*    _context;
    GLuint          _colorRenderBuffer;
    GLuint          _frameBuffer;
    
    GLuint          _program;
    GLuint          _vbo;
    GLuint          _texture;
    int             _vertCount;
}
@end
