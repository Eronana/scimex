#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Carbon/Carbon.h>
#import "hook.h"

@interface SCIMEX : NSObject
- (NSString *) convertedPunctuationFromString: (NSString* ) string;
- (BOOL) handleEvent: (NSEvent *) event client: (id) sender;
- (void) updateSettingsForKeyboardLayout;
@end

// 检查是否初始化
void checkInit(id self)
{
    static BOOL isinitialized = NO;
    if(isinitialized)return;
    // 没有初始化就用内置的函数把键盘样式设为ASCII
    [self setCapsLockEnabled: YES];
    isinitialized = YES;
}

@implementation SCIMEX
IMP _handleEvent;

+ (void) load
{
    NSLog(@"scimex has been injected.\n");
    Class CIMPinyinEngine = nil;
    while(true)
    {
        if((CIMPinyinEngine=NSClassFromString(@"CIMPinyinEngine")))break;
        usleep(100000);
        NSLog(@"Waitting for CIMPinyinEngine loading.\n");
    }
    
    NSLog(@"Hooking method.\n");
    hook_method(
         CIMPinyinEngine,@selector(convertedPunctuationFromString:),
         self,@selector(convertedPunctuationFromString:)
         );

    _handleEvent = hook_method(
        CIMPinyinEngine,@selector(handleEvent:client:),
        self,@selector(handleEvent:client:)
        );

    hook_method(
        CIMPinyinEngine,@selector(updateSettingsForKeyboardLayout),
        self,@selector(updateSettingsForKeyboardLayout)
        );
    NSLog(@"Load done.\n");
}

// 原用于将英文符号转换为中文符号
- (NSString *) convertedPunctuationFromString: (NSString* ) string
{
    // 原样返回, 什么也不做, 这是坠吼的
    return string;
}

// 是否按过了shift, 用于切换中英文
BOOL isShift = NO;
// 是否按下了shift, 用于判断是否是单纯的按下了shift, 还是shift组合按键
BOOL shiftFlag;

// 处理按键事件
- (BOOL) handleEvent: (NSEvent *) event client: (id) sender
{
    // 检查初始化
    checkInit(self);
    unsigned int modifierFlags = [event modifierFlags];
    NSString *inputText = [[self mecabraEngine] inputText];
    int inputTextLength = [inputText length];
    NSEventType type = [event type];

    if(type==NSEventTypeFlagsChanged)
    {
        // 只有在没有按下CAPSLOCK时, 才响应shift
        if(!(modifierFlags&NSEventModifierFlagCapsLock))
        {
            // 按下shift 设定flag
            if(modifierFlags&NSEventModifierFlagShift)shiftFlag=YES;
            // 松开shift
            else if(!modifierFlags&&shiftFlag)
            {
                shiftFlag=NO;
                isShift = !isShift;
                // 已经输入文本的情况下按了shift, 就提交inline文本
                if(inputTextLength)[self commitInlineTextCandidate];
            }
        }
    }

    if (type != NSEventTypeKeyDown) return NO;

    // shift+XX, 不是单独按下shift
    if(modifierFlags&NSEventModifierFlagShift)shiftFlag=NO;

    // 输入法不处理shift状态下的输入法
    if(isShift)return NO;

    // 按下Capslock
    if(modifierFlags&NSEventModifierFlagCapsLock&&!(inputTextLength&&[event keyCode]==kVK_Return))
    {
        // 已经输入文本的情况下按了Capslock,并且当前输入不为Return时, 提交所选候选文本
        [self commitSelectedCandidate];
        return NO;
    }
    return (BOOL)_handleEvent(self,_cmd,event,sender);
}

- (void) updateSettingsForKeyboardLayout
{
    // 空函数的目的就是什么也不做,这是坠吼的
    // 键盘布局改为ASCII后, 就再也不改了
}
@end
