#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "LPDDRange.h"
#import "NSNumber+LPCHSExtensions.h"

LPDDRange LPDDUnionRange(LPDDRange range1, LPDDRange range2) {
  LPDDRange result;

  result.location = MIN(range1.location, range2.location);
  result.length = MAX(LPDDMaxRange(range1), LPDDMaxRange(range2)) - result.location;

  return result;
}

LPDDRange LPDDIntersectionRange(LPDDRange range1, LPDDRange range2) {
  LPDDRange result;

  if ((LPDDMaxRange(range1) < range2.location) || (LPDDMaxRange(range2) < range1.location)) {
    return LPDDMakeRange(0, 0);
  }

  result.location = MAX(range1.location, range2.location);
  result.length = MIN(LPDDMaxRange(range1), LPDDMaxRange(range2)) - result.location;

  return result;
}

NSString *LPDDStringFromRange(LPDDRange range) {
  return [NSString stringWithFormat:@"{%qu, %qu}", range.location, range.length];
}

LPDDRange LPDDRangeFromString(NSString *aString) {
  LPDDRange result = LPDDMakeRange(0, 0);

  // NSRange will ignore '-' characters, but not '+' characters
  NSCharacterSet *cset = [NSCharacterSet characterSetWithCharactersInString:@"+0123456789"];

  NSScanner *scanner = [NSScanner scannerWithString:aString];
  [scanner setCharactersToBeSkipped:[cset invertedSet]];

  NSString *str1 = nil;
  NSString *str2 = nil;

  BOOL found1 = [scanner scanCharactersFromSet:cset intoString:&str1];
  BOOL found2 = [scanner scanCharactersFromSet:cset intoString:&str2];

  if (found1) [NSNumber parseString:str1 intoUInt64:&result.location];
  if (found2) [NSNumber parseString:str2 intoUInt64:&result.length];

  return result;
}

NSInteger LPDDRangeCompare(LPDDRangePointer pLPDDRange1, LPDDRangePointer pLPDDRange2) {
  // Comparison basis:
  // Which range would you encouter first if you started at zero, and began walking towards infinity.
  // If you encouter both ranges at the same time, which range would end first.

  if (pLPDDRange1->location < pLPDDRange2->location) {
    return NSOrderedAscending;
  }
  if (pLPDDRange1->location > pLPDDRange2->location) {
    return NSOrderedDescending;
  }
  if (pLPDDRange1->length < pLPDDRange2->length) {
    return NSOrderedAscending;
  }
  if (pLPDDRange1->length > pLPDDRange2->length) {
    return NSOrderedDescending;
  }

  return NSOrderedSame;
}

@implementation NSValue (NSValueLPDDRangeExtensions)

+ (NSValue *)valueWithLPDDRange:(LPDDRange)range {
  return [NSValue valueWithBytes:&range objCType:@encode(LPDDRange)];
}

- (LPDDRange)lpDDRangeValue {
  LPDDRange result;
  [self getValue:&result];
  return result;
}

- (NSInteger)lpDDRangeCompare:(NSValue *)other {
  LPDDRange r1 = [self lpDDRangeValue];
  LPDDRange r2 = [other lpDDRangeValue];

  return LPDDRangeCompare(&r1, &r2);
}

@end
