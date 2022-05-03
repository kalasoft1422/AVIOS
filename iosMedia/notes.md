#  <#Title#>

app launching - https://developer.apple.com/documentation/uikit/app_and_environment/responding_to_the_launch_of_your_app


METAL:
The MTLDevice allows you to create command queues. The queues hold command buffers, and the buffers in turn contain encoders that attach commands for the GPU.

Command queues are expensive to create, so they are reused rather than destroyed when they have finished executing their current instructions.
