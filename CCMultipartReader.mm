//
//  CCMultipartReader.mm
//  CCMultipartReader
//
//  Copyright 2011 CodeCatalyst, LLC. All rights reserved.
//

#import "CCMultipartReader.h"

#include "MultipartReader.h"

@implementation CCMultipartReader

@synthesize delegate = delegate_;

@synthesize boundary = boundary_;

#pragma mark - Callback functions 

void onPartBegin(const MultipartHeaders &headers, void *userData)
{
    CCMultipartReader *reader = (CCMultipartReader *)userData;
    
    NSMutableDictionary *headerDictionary = [[NSMutableDictionary alloc] init];
    MultipartHeaders::const_iterator it;
    for (it = headers.begin(); it != headers.end(); it++) {
        NSString *key   = [NSString stringWithCString:it->first.c_str() encoding:NSUTF8StringEncoding];
        NSString *value = [NSString stringWithCString:it->second.c_str() encoding:NSUTF8StringEncoding]; 
        
        [headerDictionary setValue:value forKey:key];
    }    
    
    if (reader.delegate && [reader.delegate respondsToSelector:@selector(readerDidBeginPart:headers:)])
        [reader.delegate readerDidBeginPart:reader headers:headerDictionary];
    
    [headerDictionary release];
}

void onPartData(const char *buffer, size_t size, void *userData)
{
    CCMultipartReader *reader = (CCMultipartReader *)userData;
    
    NSData *data = [[NSData alloc] initWithBytesNoCopy:(void *)buffer length:size freeWhenDone:NO];
    
    if (reader.delegate && [reader.delegate respondsToSelector:@selector(reader:didReadPartData:)])
        [reader.delegate reader:reader didReadPartData:data];
    
    [data release];
}

void onPartEnd(void *userData)
{
    CCMultipartReader *reader = (CCMultipartReader *)userData;
    
    if (reader.delegate && [reader.delegate respondsToSelector:@selector(readerDidEndPart:)])
        [reader.delegate readerDidEndPart:reader];
}

void onEnd(void *userData)
{
    CCMultipartReader *reader = (CCMultipartReader *)userData;
    
    if (reader.delegate && [reader.delegate respondsToSelector:@selector(readerDidFinishReading:)])
        [reader.delegate readerDidFinishReading:reader];
}

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        reader = new MultipartReader();
        reader->onPartBegin = onPartBegin;
        reader->onPartData = onPartData;
        reader->onPartEnd = onPartEnd;
        reader->onEnd = onEnd;
        reader->userData = self;
    }
    return self;
}

#pragma mark - Properties

- (void)setBoundary:(NSString *)value
{
    if (boundary_ != value)
    {
        [boundary_ release];
        boundary_ = [value copy];
        
        reader->setBoundary([value UTF8String]);
    }
}

- (NSString*)errorMessage
{
    return [NSString stringWithCString:reader->getErrorMessage() encoding:NSUTF8StringEncoding];
}

- (BOOL)hasError
{
    return reader->hasError();
}

- (BOOL)stopped
{
    return reader->stopped();
}

- (BOOL)succeeded
{
    return reader->succeeded();
}

#pragma mark - Methods

- (void)reset
{
    reader->reset();
}

- (size_t)read:(NSData*)data
{
    return reader->feed((const char*)[data bytes], [data length]);
}

#pragma mark - Memory Management

- (void)dealloc
{
    [boundary_ release];
    
    delete reader;
    
    [super dealloc];
}

@end
