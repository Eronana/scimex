#import <objc/runtime.h>
#import <Foundation/Foundation.h>

IMP hook_method(Class destClass,SEL destMethod,Class hookClass,SEL hookMethod);
