#include "injector.h"

#include <CoreFoundation/CoreFoundation.h>
#include <sys/types.h>
#include <sys/event.h>
#include <sys/time.h>
#include <stdio.h>
#include <cassert>
#include <cstring>
#include <dlfcn.h>
#include <stdlib.h>

void inject_scim();
void process_termination_event(dispatch_source_t dsp)
{
    dispatch_source_cancel(dsp);
    inject_scim();
}

void MonitorProcessTermination(pid_t pid)
{    

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t dsp = dispatch_source_create(DISPATCH_SOURCE_TYPE_PROC, pid, DISPATCH_PROC_EXIT, queue);

    dispatch_source_set_event_handler_f(dsp, (dispatch_function_t)process_termination_event);
    dispatch_source_set_cancel_handler_f(dsp,  (dispatch_function_t)dispatch_release);
    dispatch_set_context(dsp, dsp);
    dispatch_resume(dsp);
}

#define INJECT_FILE "/Library/Containers/com.apple.inputmethod.SCIM/Data/scimex.dylib"
Injector injector;
char INJECT_PATH[1024];
void inject_scim()
{
    pid_t pid;
getprocess:
    while(true)
    {
        if((pid=injector.getProcessByName("SCIM_Extension")))break;
        usleep(100000);
    }
    if(!injector.inject(pid, INJECT_PATH))goto getprocess;
    MonitorProcessTermination(pid);
}

int main(int argc, char* argv[])
{
    strcat(INJECT_PATH,argv[1]);
    strcat(INJECT_PATH,INJECT_FILE);
    fprintf(stderr,"dylib: %s\n", INJECT_PATH);
    inject_scim();
    CFRunLoopRun();
    return 0;
}