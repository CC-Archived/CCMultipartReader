//
//  CCMultipartReader.h
//  CCMultipartReader
//
//  Copyright 2011 CodeCatalyst, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#if defined __cplusplus
class MultipartReader;
#else
typedef struct MultipartReader MultipartReader;
#endif

@protocol CCMultipartReaderDelegate;

@interface CCMultipartReader : NSObject {
    MultipartReader *reader;
}

@property (nonatomic, assign) id<CCMultipartReaderDelegate> delegate;

@property (nonatomic, copy) NSString *boundary;
@property (nonatomic, readonly, copy) NSString *errorMessage;
@property (nonatomic, readonly, assign) BOOL hasError;
@property (nonatomic, readonly, assign) BOOL stopped;
@property (nonatomic, readonly, assign) BOOL succeeded;

- (void)reset;
- (size_t)read:(NSData*)buffer;

@end

@protocol CCMultipartReaderDelegate <NSObject>

@optional
- (void)readerDidBeginPart:(CCMultipartReader *)reader headers:(NSDictionary *)headers;
- (void)reader:(CCMultipartReader *)reader didReadPartData:(NSData *)data;
- (void)readerDidEndPart:(CCMultipartReader *)reader;
- (void)readerDidFinishReading:(CCMultipartReader *)reader;

@end

