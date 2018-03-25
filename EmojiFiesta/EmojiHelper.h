#import "EmojiCategory.h"

@interface NSObject (UIKeyboardEmojiCategory)

+ (NSArray *)categories;
+ (NSInteger)numberOfCategories;
+ (id)categoryForType:(NSInteger)type;
+ (id)computeEmojiFlagsSortedByLanguage;
+ (NSString *)displayName:(long long)arg;

@end

@interface EmojiHelper : NSObject

+ (NSArray<NSString *> *)getRecentlyUsedEmojis;
+ (NSArray<NSString *> *)getAllEmojis;
+ (NSArray<EmojiCategory *> *)getAllEmojisInCategories;

@end
