//
//  ViewController.m
//  iosMedia
//
//  Created by kalasoft on 5/3/22.
//

#import "ViewController.h"

static float quadVertexData[] =
{
     0.5, -0.5, 0.0, 1.0,     1.0, 0.0, 0.0, 1.0,
    -0.5, -0.5, 0.0, 1.0,     0.0, 1.0, 0.0, 1.0,
    -0.5,  0.5, 0.0, 1.0,     0.0, 0.0, 1.0, 1.0,
    
     0.5,  0.5, 0.0, 1.0,     1.0, 1.0, 0.0, 1.0,
     0.5, -0.5, 0.0, 1.0,     1.0, 0.0, 0.0, 1.0,
    -0.5,  0.5, 0.0, 1.0,     0.0, 0.0, 1.0, 1.0,
};

@interface ViewController ()



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMetal];
    NSLog(@"iosMedia Loaded");
    // Set up the render loop to redraw in sync with the main screen refresh rate
        self.timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(redraw)];
        [self.timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

    // Do any additional setup after loading the view.
}

-(void)setupMetal{
    self.device = MTLCreateSystemDefaultDevice();

    // Create, configure, and add a Metal sublayer to the current layer
    self.metalLayer = [CAMetalLayer layer];
    self.metalLayer.device = self.device;
    self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    self.metalLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.metalLayer];
    
    self.defaultLibrary = [self.device newDefaultLibrary];
    id<MTLFunction> vertexProg = [self.defaultLibrary newFunctionWithName:@"basic_vertex"];
    id<MTLFunction> fragProg = [self.defaultLibrary newFunctionWithName:@"basic_fragment"];
    
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    [pipelineStateDescriptor setVertexFunction:vertexProg];
    [pipelineStateDescriptor setFragmentFunction:fragProg];
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    

    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:nil];
    
    _vertexBuffer = [_device newBufferWithBytes:quadVertexData length:sizeof(quadVertexData) options:MTLResourceOptionCPUCacheModeDefault];
    // Create a long-lived command queue
    _uniformBuffer = [_device newBufferWithLength:sizeof(Uniforms)
                                        options:MTLResourceOptionCPUCacheModeDefault];


    /*
     //To copy the rotation matrix into the uniform buffer, we get a pointer to its contents and memcpy the matrix into it:


     Uniforms uniforms;
     uniforms.rotation_matrix = rotation_matrix_2d(rotationAngle);
     void *bufferPointer = [uniformBuffer contents];
     memcpy(bufferPointer, &uniforms, sizeof(Uniforms));

     */
    //get drawable from metal layer
    _currentDrawable = [_metalLayer nextDrawable];
    
    //command q and encoder
    self.commandQueue = [self.device newCommandQueue];

    
    NSLog(@"Metal setup");

    
}

- (MTLRenderPassDescriptor *)renderPassDescriptorForTexture:(id<MTLTexture>) texture
{
    // Configure a render pass with properties applicable to its single color attachment (i.e., the framebuffer)
    MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    renderPassDescriptor.colorAttachments[0].texture = texture;
    renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 0, 1, 1);
    renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    return renderPassDescriptor;
}

- (void)redraw {
    @autoreleasepool {
        if (self.layerSizeDidUpdate) {
            // Ensure that the drawable size of the Metal layer is equal to its dimensions in pixels
            CGFloat nativeScale = self.view.window.screen.nativeScale;
            CGSize drawableSize = self.metalLayer.bounds.size;
            drawableSize.width *= nativeScale;
            drawableSize.height *= nativeScale;
            self.metalLayer.drawableSize = drawableSize;

            self.layerSizeDidUpdate = NO;
        }
        
        // Draw the scene
        [self render];
        
        self.currentDrawable = nil;
    }
}

-(void)render{
   // [self update];
        
        id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
        id<CAMetalDrawable> drawable = [self currentDrawable];
    
    
    MTLRenderPassDescriptor *renderPassDescriptor = [self renderPassDescriptorForTexture:drawable.texture];
    // Prepare a render command encoder with the current render pass
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    
    
    // Configure and issue our draw call
        [renderEncoder setRenderPipelineState:self.pipelineState];
        [renderEncoder setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
        [renderEncoder setVertexBuffer:self.uniformBuffer offset:0 atIndex:1];
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];

    [renderEncoder endEncoding];
    [commandBuffer presentDrawable:drawable];
    // Finalize the command buffer and commit it to its queue
    [commandBuffer commit];
    NSLog(@"rendered");

}

- (id <CAMetalDrawable>)currentDrawable {
    // Our drawable may be nil if we're not on the screen or we've taken too long to render.
    // Block here until we can draw again.
    while (_currentDrawable == nil) {
        _currentDrawable = [self.metalLayer nextDrawable];
    }
    
    return _currentDrawable;
}

@end
