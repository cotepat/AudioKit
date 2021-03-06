// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKSporthStack.h"
#import "AKOperationEffectDSPKernel.hpp"

@implementation AKSporthStack
{
  sporth_stack *_stack;
}

- (void)setStack:(sporth_stack *)stack
{
  _stack = stack;
}

- (const char *)popString
{
  return sporth_stack_pop_string(_stack);
}

- (float)popFloat
{
  return sporth_stack_pop_float(_stack);
}

- (void)pushFloat:(float)f
{
  sporth_stack_push_float(_stack, f);
}

- (void)pushString:(char *)str
{
  sporth_stack_push_string(_stack, &str);
}

@end
