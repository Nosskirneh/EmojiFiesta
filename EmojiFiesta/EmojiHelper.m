#import "EmojiHelper.h"

@implementation EmojiHelper

+ (NSArray<NSString *> *)getRecentlyUsedEmojis {
    NSUserDefaults *emojiPrefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.apple.EmojiPreferences"];
    NSDictionary *emojiPrefsDict = [emojiPrefs dictionaryRepresentation];
    if (emojiPrefsDict[@"EMFDefaultsKey"][@"EMFRecentsKey"])
        return emojiPrefsDict[@"EMFDefaultsKey"][@"EMFRecentsKey"];
    else if (emojiPrefsDict[@"EmojiDefaultsKey"][@"EmojiRecentsDefaultsKey"][@"RecentsKey"])
        return emojiPrefsDict[@"EmojiDefaultsKey"][@"EmojiRecentsDefaultsKey"][@"RecentsKey"];

    return nil;
}

+ (NSArray<NSString *> *)getAllEmojis {
    // Let's get a reference to Apple's UIKeyboardEmojiCategory class
    Class UIKeyboardEmojiCategory = NSClassFromString(@"UIKeyboardEmojiCategory");

    NSMutableArray *allEmojis = [NSMutableArray array];

    // Loop over all categories
    for (int i = 0; i < [UIKeyboardEmojiCategory categories].count; i++) {
        id category = [UIKeyboardEmojiCategory categoryForType:i];

        // Let's get thte category name
        NSString *categoryName = [category performSelector:@selector(name)];

        // Ignore the 'recent' category, so we only get unique Emoji
        if ([categoryName hasSuffix:@"Recent"]) {
            continue;
        }

        // The flags category is a bit special on iOS < 10.1.1
        if ([UIKeyboardEmojiCategory respondsToSelector:@selector(computeEmojiFlagsSortedByLanguage)] &&
            [categoryName hasSuffix:@"Flags"]) {
            // flagEmoji contains the emoji itself
            NSArray *flagEmoji = [UIKeyboardEmojiCategory computeEmojiFlagsSortedByLanguage];
            [allEmojis addObjectsFromArray:flagEmoji];
            continue;
        }

        NSMutableArray *emojiArray = [category valueForKey:@"emoji"];

        for (id emojiItem in emojiArray) {
            // Emoji! 🎉
            NSString *emojiString = [emojiItem valueForKey:@"emojiString"];
            // Add the emoji
            [allEmojis addObject:emojiString];
        }
    }
    return allEmojis;
}

+ (NSArray<EmojiCategory *> *)getAllEmojisInCategories {
    // Let's get a reference to Apple's UIKeyboardEmojiCategory class
    Class UIKeyboardEmojiCategory = NSClassFromString(@"UIKeyboardEmojiCategory");

    NSMutableArray *allCategories = [NSMutableArray array];

    // Loop over all categories
    for (int i = 0; i < [UIKeyboardEmojiCategory categories].count; i++) {
        id category = [UIKeyboardEmojiCategory categoryForType:i];

        // Let's get the category name
        NSString *categoryName = [category performSelector:@selector(name)];

        // Ignore the 'recent' category, so we only get unique emojis
        // The "Recent" category appears twice (at least on iOS 10.2); the second time without categoryName
        // The "Celebration" category is empty (at least on iOS 10.2)
        if (!categoryName || [categoryName hasSuffix:@"Recent"] || ![category valueForKey:@"emoji"]) {
            continue;
        }

        // Get the display name for the current category
        NSString *displayName = [UIKeyboardEmojiCategory displayName:i];

        // Instanciate our own category container
        EmojiCategory *emojiCategory = [EmojiCategory new];
        emojiCategory.name = displayName;
        emojiCategory.id = categoryName;

        // The flags category is a bit special on iOS < 10.1.1
        if ([UIKeyboardEmojiCategory respondsToSelector:@selector(computeEmojiFlagsSortedByLanguage)] &&
            [categoryName hasSuffix:@"Flags"]) {
            // flagEmoji contains the emojis itself
            NSArray *flagEmoji = [UIKeyboardEmojiCategory computeEmojiFlagsSortedByLanguage];
            NSMutableArray *arrFlagEmoji = [NSMutableArray new];
            
            // Loop over every flag & wrap them in a dict so it conforms to the other categories
            for (NSString *flag in flagEmoji) {
                [arrFlagEmoji addObject:@{
                                          @"emojiString": flag,
                                          @"variantMask": @0
                                         }];
            }

            // Set all the emoji on the flag category
            [category setEmoji:arrFlagEmoji];
            continue;
        }

        // Let's create an array of emojis for this category
        NSMutableArray *categoryEmoji = [NSMutableArray array];
        NSMutableArray *emojiArray = [category valueForKey:@"emoji"];

        for (id emojiItem in emojiArray) {
            // Emoji! 🎉
            NSString *emojiString = [emojiItem valueForKey:@"emojiString"];

            // Create our own emoji container
            Emoji *emoji = [Emoji new];
            emoji.emojiString = emojiString;

            // Let's create the variations container
            NSMutableArray<NSString *> *emojiVariations = [NSMutableArray new];
            [emojiVariations addObject:emojiString];

            // Variant mask indicates whether or not there are variations for a given emoji
            int vmask = [[emojiItem valueForKey:@"variantMask"] intValue];

            // Fritzpatrick scale https://en.wikipedia.org/wiki/Fitzpatrick_scale
            // Diversity http://www.unicode.org/reports/tr51/index.html#Diversity
            if (vmask == 2 || vmask == 3) {
                // These codes are specified on the unicode consortium website
                [emojiVariations addObject:[NSString stringWithFormat:@"%@\U0001F3FB", emojiString]]; // 1-2
                [emojiVariations addObject:[NSString stringWithFormat:@"%@\U0001F3FC", emojiString]]; // 3
                [emojiVariations addObject:[NSString stringWithFormat:@"%@\U0001F3FD", emojiString]]; // 4
                [emojiVariations addObject:[NSString stringWithFormat:@"%@\U0001F3FE", emojiString]]; // 5
                [emojiVariations addObject:[NSString stringWithFormat:@"%@\U0001F3FF", emojiString]]; // 6
            }

            // Set the variations
            emoji.variations = emojiVariations;

            // Add the emoji to the category
            [categoryEmoji addObject:emoji];
        }

        // Set all the emoji on the category
        emojiCategory.emoji = categoryEmoji;

        // Add the category to the return array
        [allCategories addObject:emojiCategory];
    }

    // Put Flags at the bottom
    for (long i = allCategories.count - 1; i > 0; i--) {
        EmojiCategory *category = allCategories[i];
        if ([category.id hasSuffix:@"Flags"]) {
            [allCategories removeObjectAtIndex:i];
            [allCategories insertObject:category atIndex:allCategories.count];
            break;
        }
    }

    return allCategories;
}

@end
