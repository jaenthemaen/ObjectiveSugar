//
//  NSDictionary+ObjectiveSugar.m
//  SampleProject
//
//  Created by Marin Usalj on 11/23/12.
//  Copyright (c) 2012 @supermarin | supermar.in. All rights reserved.
//

#import "NSDictionary+ObjectiveSugar.h"

#import "NSArray+ObjectiveSugar.h"

@implementation NSDictionary (Rubyfy)

- (void)each:(void (^)(id k, id v))block {
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        block(key, obj);
    }];
}

- (void)eachKey:(void (^)(id k))block {
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        block(key);
    }];
}

- (void)eachValue:(void (^)(id v))block {
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        block(obj);
    }];
}

- (NSArray *)map:(id (^)(id key, id value))block {
    NSMutableArray *array = [NSMutableArray array];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id object = block(key, obj);
        if (object) {
          [array addObject:object];
        }
    }];
    
    return array;
}

- (BOOL)hasKey:(id)key {
    return !!self[key];
}

- (NSArray<id> *)valuesForKeys:(NSSet<NSString *> *)keys {
    if (!keys.count) return @[];
    
    NSMutableArray *result = [NSMutableArray new];
    for (NSString *key in self.allKeys) {
        if ([keys containsObject:key]) {
            [result addObject:self[key]];
        }
    }
    return [result copy];
}

@end
