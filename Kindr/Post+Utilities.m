//
//  Post+Utilities.m
//  Kindr
//
//  Created by Kyle Lucovsky on 3/9/15.
//  Copyright (c) 2015 Kyle Lucovsky. All rights reserved.
//

#import "Post+Utilities.h"

@implementation Post (Utilities)

- (NSString *)parseBlockElementsFromString:(NSString *)content
{
    NSError *error;
    NSRegularExpression *blockStartRegex = [[NSRegularExpression alloc] initWithPattern:@"<[p|div|body][^>]*>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression *blockEndRegex = [[NSRegularExpression alloc] initWithPattern:@"</p>|</div>|</body>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression *coreDecoratedRegex = [[NSRegularExpression alloc] initWithPattern:@"<!-- core-decorated -->" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression *anyTagRegex = [[NSRegularExpression alloc] initWithPattern:@"<[^>]*>" options:0 error:&error];

    NSMutableString *mutable = [content mutableCopy];
    
    mutable = [[blockStartRegex stringByReplacingMatchesInString:mutable options:0 range:NSMakeRange(0, [mutable length]) withTemplate:@""] mutableCopy];
    mutable = [[coreDecoratedRegex stringByReplacingMatchesInString:mutable options:0 range:NSMakeRange(0, [mutable length]) withTemplate:@""] mutableCopy];
    mutable = [[blockEndRegex stringByReplacingMatchesInString:mutable options:0 range:NSMakeRange(0, [mutable length]) withTemplate:@"\n"] mutableCopy];
    mutable = [[mutable stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""] mutableCopy];

    return [anyTagRegex stringByReplacingMatchesInString:mutable options:0 range:NSMakeRange(0, [mutable length]) withTemplate:@""];
}
@end
