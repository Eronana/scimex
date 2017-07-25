#import "hook.h"

IMP hook_method(Class destClass,SEL destMethod,Class hookClass,SEL hookMethod)
{
    Method dMethod = class_getInstanceMethod(destClass,destMethod);
    Method hMethod = class_getInstanceMethod(hookClass,hookMethod);
    IMP dImp = method_getImplementation(dMethod);
    IMP hImp = method_getImplementation(hMethod);
    method_setImplementation(dMethod,hImp);
    return dImp;
}
