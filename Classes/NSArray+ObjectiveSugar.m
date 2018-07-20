//
//  NSArray+ObjectiveSugar.m
//  WidgetPush
//
//  Created by Marin Usalj on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSArray+ObjectiveSugar.h"
#import "NSMutableArray+ObjectiveSugar.h"
#import "NSString+ObjectiveSugar.h"

static NSString * const OSMinusString = @"-";

@implementation NSArray (ObjectiveSugar)

- (NSSet<id> *)set {
    return [NSSet setWithArray:self];
}

- (NSMutableSet<id> *)mutableSet {
    return [NSMutableSet setWithArray:self];
}

- (NSOrderedSet<id> *)orderedSet {
    return [NSOrderedSet orderedSetWithArray:self];
}

- (NSMutableOrderedSet<id> *)mutableOrderedSet {
    return [NSMutableOrderedSet orderedSetWithArray:self];
}

- (id)first {
    if (self.count > 0)
        return self[0];

    return nil;
}

- (id)last {
    return self.lastObject;
}

- (id)sample {
    if (self.count == 0) return nil;

    NSUInteger index = arc4random_uniform((u_int32_t)self.count);
    return self[index];
}

- (id)objectForKeyedSubscript:(id)key {
    if ([key isKindOfClass:[NSString class]])
        return [self subarrayWithRange:[self rangeFromString:key]];
    
    else if ([key isKindOfClass:[NSValue class]])
        return [self subarrayWithRange:[key rangeValue]];
    
    else
        [NSException raise:NSInvalidArgumentException format:@"expected NSString or NSValue argument, got %@ instead", [key class]];
    
    return nil;
}

- (NSRange)rangeFromString:(NSString *)string {
    NSRange range = NSRangeFromString(string);
    
    if ([string containsString:@"..."]) {
        range.length = isBackwardsRange(string) ? (self.count - 2) - range.length : range.length - range.location;
        
    } else if ([string containsString:@".."]) {
        range.length = isBackwardsRange(string) ? (self.count - 1) - range.length : range.length - range.location + 1;
    }
    
    return range;
}

- (void)each:(void (^)(id object))block {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj); 
    }];
}

- (void)eachWithIndex:(void (^)(id object, NSUInteger  index))block {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj, idx); 
    }];
}

- (BOOL)includes:(id)object {
    return [self containsObject:object];
}

- (NSArray<id> *)take:(NSUInteger)numberOfElements {
    numberOfElements = MIN(numberOfElements, [self count]);
    NSMutableArray *array = [NSMutableArray new];

    for (NSUInteger i = 0; i < numberOfElements; i++) {
        [array addObject:self[i]];
    }

    return array;
}

- (NSArray<id> *)takeWhile:(BOOL (^)(id object))block {
    NSMutableArray *array = [NSMutableArray new];

    for (id arrayObject in self) {
        if (block(arrayObject))
            [array addObject:arrayObject];

        else break;
    }

    return array;
}

- (NSArray<id> *)map:(id (^)(id object))block {
    NSMutableArray *array = [NSMutableArray new];

    for (id object in self) {
        id newObject = block(object);
        if (newObject) {
          [array addObject:newObject];
        }
    }

    return array;
}

- (NSArray<id> *)select:(BOOL (^)(id object))block {
    NSMutableArray *array = [NSMutableArray new];

    for (id object in self) {
        if (block(object)) {
            [array addObject:object];
        }
    }

    return array;
}

- (id)detect:(BOOL (^)(id object))block {

    for (id object in self) {
        if (block(object))
            return object;
    }

    return nil;
}

- (id)find:(BOOL (^)(id object))block {
    return [self detect:block];
}

- (NSArray<id> *)reject:(BOOL (^)(id object))block {
    NSMutableArray *array = [NSMutableArray new];

    for (id object in self) {
        if (block(object) == NO) {
            [array addObject:object];
        }
    }

    return array;
}

- (NSArray<id> *)flatten {
    NSMutableArray *array = [NSMutableArray new];
    for (id object in self) {
        if ([object isKindOfClass:NSArray.class]) {
            [array concat:[object flatten]];
        } else if ([object isKindOfClass:NSSet.class]) {
            [array concat:[((NSSet*)object).allObjects flatten]];
        } else if ([object isKindOfClass:NSOrderedSet.class]) {
            [array concat:[[object array] flatten]];
        } else if ([object isKindOfClass:NSDictionary.class]) {
            [array concat:[[object allValues] flatten]];
        } else {
            [array addObject:object];
        }
    }

    return array;
}

- (NSString *)join {
    return [self componentsJoinedByString:@""];
}

- (NSString *)join:(NSString *)separator {
    return [self componentsJoinedByString:separator];
}

- (NSArray<id> *)sort {
    return [self sortedArrayUsingSelector:@selector(compare:)];
}

- (NSArray<id> *)sortBy:(NSString*)key; {
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];
    return [self sortedArrayUsingDescriptors:@[descriptor]];
}

- (NSArray<id> *)sortByKeyPaths:(NSArray<id> *)keyPaths {
    NSMutableArray *descriptors = [NSMutableArray new];
    for (NSString *keyPath in keyPaths) {
        [descriptors addObject:[NSSortDescriptor sortDescriptorWithKey:keyPath ascending:YES]];
    }
    return [self sortedArrayUsingDescriptors:descriptors];
}

- (NSArray<id> *)reverse {
    return self.reverseObjectEnumerator.allObjects;
}

#pragma mark - Set operations

- (NSArray<id> *)intersectionWithArray:(NSArray<id> *)array {
    NSPredicate *intersectPredicate = [NSPredicate predicateWithFormat:@"SELF IN %@", array];
    return [self filteredArrayUsingPredicate:intersectPredicate];
}

- (NSArray<id> *)unionWithArray:(NSArray<id> *)array {
    NSArray<id> *complement = [self relativeComplement:array];
    return [complement arrayByAddingObjectsFromArray:array];
}

- (NSArray<id> *)relativeComplement:(NSArray<id> *)array {
    NSPredicate *relativeComplementPredicate = [NSPredicate predicateWithFormat:@"NOT SELF IN %@", array];
    return [self filteredArrayUsingPredicate:relativeComplementPredicate];
}

- (NSArray<id> *)symmetricDifference:(NSArray<id> *)array {
    NSArray<id> *aSubtractB = [self relativeComplement:array];
    NSArray<id> *bSubtractA = [array relativeComplement:self];
    return [aSubtractB unionWithArray:bSubtractA];
}

- (NSArray<id> *)filteredArrayByDistinctValuesOfKeyPath:(NSString *)keyPath {
    return [[self groupWithDistinctValuesBy:keyPath].allValues flatten];
}

- (NSArray<id> *)arrayByRemovingObject:(id)anObject {
    if (!anObject) return self;
    
    NSMutableArray *mutArray = [self mutableCopy];
    [mutArray removeObject:anObject];
    return [mutArray copy];
}

- (NSArray<id> *)arrayByRemovingObjectsFromArray:(NSArray<id> *)otherArray {
    if (otherArray.count == 0) return self;
    
    NSMutableArray *mutArray = [self mutableCopy];
    [mutArray removeObjectsInArray:otherArray];
    return [mutArray copy];
}

- (NSArray<id> *)distinctValuesForKeyPath:(NSString *)keyPath {
    if (!keyPath.length) return self;
    return [self valueForKeyPath:[NSString stringWithFormat:@"@distinctUnionOfObjects.%@", keyPath]];
}

- (NSArray<id> *)flattenedValuesForKeyPath:(NSString *)keyPath {
    return [[self valueForKeyPath:keyPath] flatten];
}

- (NSArray<id> *)distinctFlattenedValuesForKeyPath:(NSString *)keyPath {
    return [[self valueForKeyPath:keyPath] distinctFlatten];
}

- (NSArray<id> *)nonNullValuesForKeyPath:(NSString *)keyPath {
    return [[self valueForKeyPath:keyPath] filterNull];
}

- (NSArray<id> *)sortedValuesForKeyPath:(NSString *)keyPath {
    return [[self valueForKeyPath:keyPath] sort];
}

- (NSArray<id> *)distinctFlatten {
    return [[self flatten].orderedSet.array copy];
}

- (NSArray<id> *)filterNull {
    return [self filteredArrayUsingFormat:@"self != %@", [NSNull null]];
}

- (NSArray<id> *)flatMap:(id (^)(id object))block {
    return [[self flatten] map:block];
}

- (NSArray<id> *)distinctFlatMap:(id (^)(id object))block {
    return [[self distinctFlatten] map:block];
}

- (BOOL)containsArray:(NSArray<id> *)array {
    if (!array.count) return NO;
    
    for (id object in array) {
        if (![self containsObject:object]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Private

static inline BOOL isBackwardsRange(NSString *rangeString) {
    return [rangeString containsString:OSMinusString];
}

@end


@implementation NSArray (Grouping)

- (NSDictionary<__kindof id<NSCopying>, NSArray<id> *> *)groupBy:(NSString *)keyPath {
    NSMutableDictionary *group = [NSMutableDictionary new];
    for (id elem in self) {
        id groupKey = [elem valueForKeyPath:keyPath];
        if (groupKey) {
            NSMutableArray *entries = group[groupKey] ?: [NSMutableArray new];
            [entries addObject:elem];
            group[groupKey] = entries;
        }
    }
    return group;
}

- (NSDictionary<NSString *, NSArray<__kindof NSObject *> *> *)groupByStringIDsInArrayAtKeypath:(NSString *)keyPath {
    NSMutableDictionary *groups = [NSMutableDictionary new];
    for (__kindof NSObject *obj in self) {
        NSArray<NSString *> *groupKeys = [obj valueForKeyPath:keyPath];
        if (groupKeys.count) {
            for (NSString *key in groupKeys) {
                NSMutableArray *entries = groups[key] ?: [NSMutableArray new];
                [entries addObject:obj];
                groups[key] = entries;
            }
        }
    }
    return groups;
}

- (NSDictionary<__kindof id<NSCopying>, NSNumber *> *)groupWithCountedValuesBy:(NSString *)keyPath {
    NSMutableDictionary *group = [NSMutableDictionary new];
    for (id elem in self) {
        id groupKey = [elem valueForKeyPath:keyPath];
        if (groupKey) {
            NSNumber *count = group[groupKey] ?: @0;
            count = @(count.integerValue + 1);
            group[groupKey] = count;
        }
    }
    return group;
}

- (NSDictionary<__kindof id<NSCopying>, __kindof NSObject *> *)lookupDictionaryByKeyPath:(NSString *)keyPath {
    NSMutableDictionary *group = [NSMutableDictionary new];
    for (id elem in self) {
        id groupKey = [elem valueForKeyPath:keyPath];
        if (groupKey) {
            group[groupKey] = elem;
        }
    }
    return group;
}

- (NSDictionary <__kindof id<NSCopying>, NSArray<id> *> *)groupWithDistinctValuesBy:(NSString *)keyPath {
    NSMutableDictionary *group = [NSMutableDictionary new];
    for (id elem in self) {
        id groupKey = [elem valueForKeyPath:keyPath];
        if (groupKey) {
            NSMutableArray *entries = group[groupKey];
            if (!entries) {
                entries = [NSMutableArray new];
                [entries addObject:elem];
                group[groupKey] = entries;
            }
        }
    }
    return group;
}

- (NSDictionary<NSOrderedDictionaryKey *, NSArray<id> *> *)groupOrderedBy:(NSString *)keyPath {
    NSMutableDictionary *group = [NSMutableDictionary new];
    for (id elem in self) {
        id groupKey = [elem valueForKeyPath:keyPath];
        if (groupKey) {
            NSOrderedDictionaryKey *orderedKey = [group.allKeys firstObjectMatchingFormat:@"key = %@", groupKey];
            orderedKey = orderedKey ?: [[NSOrderedDictionaryKey alloc] initWithKey:groupKey index:group.allKeys.count];
            NSMutableArray *entries = group[orderedKey] ?: [NSMutableArray new];
            [entries addObject:elem];
            group[orderedKey] = entries;
        }
    }
    return group;
}

@end

@implementation NSOrderedDictionaryKey

- (instancetype)initWithKey:(id<NSCopying, NSObject>)key index:(NSUInteger)index {
    self = [super init];
    if (self) {
        _key = key;
        _index = index;
    }
    return self;
}

- (NSUInteger)hash {
    return _key.hash * 17 + _index * 19;
}

- (BOOL)isEqual:(id)object {
    if (!object) return NO;
    if (object == self) return YES;
    if (![object isKindOfClass:[NSOrderedDictionaryKey class]]) return NO;
    NSOrderedDictionaryKey *otherObject = (NSOrderedDictionaryKey *)object;
    return ((!self.key && !otherObject.key) || ([self.key isEqual:otherObject.key])) && self.index == otherObject.index;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithKey:_key index:_index];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; key = %@; index = %lu>", [self class], self, _key, (unsigned long)_index];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"key: %@, index: %lu", _key, (unsigned long)_index];
}

- (NSComparisonResult)compare:(NSOrderedDictionaryKey *)otherKey {
    return [@(self.index) compare:@(otherKey.index)];
}

@end

NSArray<id> *NSRangeToArray(NSRange range) {
    NSMutableArray *result = [NSMutableArray new];
    for (NSUInteger i=range.location; i<range.location+range.length; i++) {
        [result addObject:@(i)];
    }
    return result;
}
