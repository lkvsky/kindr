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

//- (NSString *)parseInlineElementsFromString:(NSString *)content
//{
//    NSError *error;
//    NSRegularExpression *tagStartRegex = [[NSRegularExpression alloc] initWithPattern:@"<[a|span|hr][^>]*>" options:NSRegularExpressionCaseInsensitive error:&error];
//    NSRegularExpression *inlineRegex = [[NSRegularExpression alloc] initWithPattern:@"</span>|<small>|</small>|</a>" options:NSRegularExpressionCaseInsensitive error:&error];
//    NSMutableString *mutable = [content mutableCopy];
//    
//    mutable = [[mutable stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""] mutableCopy];
//    mutable = [[tagStartRegex stringByReplacingMatchesInString:mutable options:0 range:NSMakeRange(0, [mutable length]) withTemplate:@""] mutableCopy];
//    mutable = [[inlineRegex stringByReplacingMatchesInString:mutable options:0 range:NSMakeRange(0, [mutable length]) withTemplate:@""] mutableCopy];
//    
//    return mutable;
//}
//
//- (NSString *)stylizeItalicElementsFromStrong:(NSString *)content
//{
//    NSError *error = nil;
//    NSRegularExpression *emRegex = [[NSRegularExpression alloc] initWithPattern:@"<em>.*</em>" options:NSRegularExpressionCaseInsensitive error:&error];
//    NSRegularExpression *tagRegex = [[NSRegularExpression alloc] initWithPattern:@"<em>|</em>" options:NSRegularExpressionCaseInsensitive error:&error];
//    NSMutableAttributedString *mutable = [[NSMutableAttributedString alloc] initWithString:content attributes:@{}];
//    
//    NSLog(@"%@", [emRegex matchesInString:mutable.string options:0 range:NSMakeRange(0, [mutable length])]);
//    [emRegex enumerateMatchesInString:content
//                              options:0
//                                range:NSMakeRange(0, [mutable length])
//                           usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
//                               [mutable addAttributes:@{NSFontAttributeName: [UIFont italicSystemFontOfSize:
//                                                                              [UIFont systemFontSize]]}
//                                                range:result.range];
//                           }];
//    
//    return [tagRegex stringByReplacingMatchesInString:mutable.string options:0 range:NSMakeRange(0, [mutable length]) withTemplate:@""];
//}
//
//- (NSString *)stylizeBoldElementsFromStrong:(NSString *)content
//{
//    NSError *error = nil;
//    NSRegularExpression *strongRegex = [[NSRegularExpression alloc] initWithPattern:@"<strong>.*</strong>" options:NSRegularExpressionCaseInsensitive error:&error];
//    NSRegularExpression *tagRegex = [[NSRegularExpression alloc] initWithPattern:@"<strong>|</strong>" options:NSRegularExpressionCaseInsensitive error:&error];
//    NSMutableAttributedString *mutable = [[NSMutableAttributedString alloc] initWithString:content attributes:@{}];
//
//    NSLog(@"%@", [strongRegex matchesInString:mutable.string options:0 range:NSMakeRange(0, [mutable length])]);
//    [strongRegex enumerateMatchesInString:content
//                              options:0
//                                range:NSMakeRange(0, [mutable length])
//                           usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
//                               NSString *subString = [mutable.string substringWithRange:result.range];
//                               [mutable addAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:[UIFont systemFontSize]]}
//                                                range:result.range];
//                               [tagRegex stringByReplacingMatchesInString:subString options:0 range:NSMakeRange(0, [subString length])withTemplate:@""];
//                           }];
//    return mutable.string;
////    return [tagRegex stringByReplacingMatchesInString:mutable.string options:0 range:NSMakeRange(0, [mutable length]) withTemplate:@""];
//}
@end
