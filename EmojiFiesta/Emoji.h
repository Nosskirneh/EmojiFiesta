#import <Foundation/Foundation.h>

@interface Emoji : NSObject
@property (nonatomic, readwrite, assign) NSString *emojiString;
@property (strong, nonatomic) NSArray<NSString *> *variations;
@end
