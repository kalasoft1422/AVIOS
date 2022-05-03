//
//  ViewController.h
//  iosMedia
//
//  Created by kalasoft on 5/3/22.
//

#import <UIKit/UIKit.h>
@import Metal;
@import simd;
@import QuartzCore.CAMetalLayer;
typedef struct
{
    matrix_float4x4 rotation_matrix;
} Uniforms;

@interface ViewController : UIViewController

// Long-lived Metal objects
@property (nonatomic, strong) CAMetalLayer *metalLayer;
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLLibrary> defaultLibrary;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipelineState;

// Resources
@property (nonatomic, strong) id<MTLBuffer> uniformBuffer;
@property (nonatomic, strong) id<MTLBuffer> vertexBuffer;

// Transient objects
@property (nonatomic, strong) id<CAMetalDrawable> currentDrawable;

@property (nonatomic, strong) CADisplayLink *timer;

@property (nonatomic, assign) BOOL layerSizeDidUpdate;
@property (nonatomic, assign) Uniforms uniforms;
@property (nonatomic, assign) float rotationAngle;

-(void)setupMetal;
-(void)render;


@end

