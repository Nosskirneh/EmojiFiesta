#import <Foundation/Foundation.h>
#import "Emoji.h"

@interface EmojiCategory : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSArray<Emoji *> *emoji;
@end
