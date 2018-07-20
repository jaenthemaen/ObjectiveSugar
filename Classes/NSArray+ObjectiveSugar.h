//
//  NSArray+ObjectiveSugar.h
//  Objective Sugar
//
//  Created by Marin Usalj on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// For an overview see http://cocoadocs.org/docsets/ObjectiveSugar/

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<__covariant ObjectType> (ObjectiveSugar)

@property (nonatomic, strong, readonly) NSSet<ObjectType> *set;
@property (nonatomic, strong, readonly) NSMutableSet<ObjectType> *mutableSet;
@property (nonatomic, strong, readonly) NSOrderedSet<ObjectType> *orderedSet;
@property (nonatomic, strong, readonly) NSMutableOrderedSet<ObjectType> *mutableOrderedSet;

/**
 The first item in the array, or nil.

 @return  The first item in the array, or nil.
 */

- (nullable ObjectType) first;

/**
 The last item in the array, or nil.

 @return  The last item in the array, or nil.
 */

- (ObjectType) last;


/**
 A random element in the array, or nil.

 @return  A random element in the array, or nil.
 */

- (nullable ObjectType) sample;


/**
 Allow subscripting to fetch elements within the specified range
 
 @param An NSString or NSValue wrapping an NSRange. It's intended to behave like Ruby's array range accessors.
 
        Given array of 10 elements, e.g. [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], you can perform these operations:
        array[@"1..3"] will give you [2, 3, 4]
        array[@"1...3"] will give you [2, 3] (last value excluded)
        array[@"1,3"] implies NSRange(location: 1, length: 3), and gives you [2, 3, 4]

 
 @return An array with elements within the specified range
 */
- (nullable ObjectType)objectForKeyedSubscript:(id <NSCopying>)key;


/**
 A simpler alias for `enumerateObjectsUsingBlock`

 @param A block with the object in its arguments.
 */

- (void)each:(void (^)(ObjectType object))block;

/**
 A simpler alias for `enumerateObjectsUsingBlock` which also passes in an index

 @param A block with the object in its arguments.
 */

- (void)eachWithIndex:(void (^)(ObjectType object, NSUInteger index))block;

/**
 An alias for `containsObject`

 @param An object that the array may or may not contain.
 */

- (BOOL)includes:(ObjectType)object;

/**
 Take the first `numberOfElements` out of the array, or the maximum amount of
 elements if it is less.

 @param Number of elements to take from array
 @return An array of elements
 */

- (NSArray<ObjectType> *)take:(NSUInteger)numberOfElements;

/**
 Passes elements to the `block` until the block returns NO, 
 then stops iterating and returns an array of all prior elements.

 @param A block that returns YES/NO
 @return An array of elements
 */
- (NSArray<ObjectType> *)takeWhile:(BOOL (^)(ObjectType object))block;

/**
 Iterate through the current array running the block on each object and
 returning an array of the changed objects.

 @param A block that passes in each object and returns a modified object
 @return An array of modified elements
 */

- (NSArray *)map:(id (^)(ObjectType object))block;

/**
 Iterate through current array asking whether to keep each element.

 @param A block that returns YES/NO for whether the object should stay
 @return An array of elements selected
 */

- (NSArray<ObjectType> *)select:(BOOL (^)(ObjectType object))block;

/**
 Iterate through current array returning the first element meeting a criteria.

 @param A block that returns YES/NO
 @return The first matching element
 */

- (nullable ObjectType)detect:(BOOL (^)(ObjectType object))block;


/**
 Alias for `detect`. Iterate through current array returning the first element
 meeting a criteria.

 @param A block that returns YES/NO
 @return The first matching element
 */

- (nullable ObjectType)find:(BOOL (^)(ObjectType object))block;

/**
 Iterate through current array asking whether to remove each element.

 @param A block that returns YES/NO for whether the object should be removed
 @return An array of elements not rejected
 */

- (NSArray<ObjectType> *)reject:(BOOL (^)(ObjectType object))block;

/**
 Recurse through self checking for NSArrays and extract all elements into one single array

 @return An array of all held arrays merged
 */

- (NSArray<ObjectType> *)flatten;

/**
 Alias for `componentsJoinedByString` with a default of no seperator

 @return A string of all objects joined with an empty string 
 */

- (NSString *)join;

/**
 Alias for `componentsJoinedByString`

 @return A string of all objects joined with the `seperator` string
 */

- (NSString *)join:(NSString *)separator;

/**
 Run the default comparator on each object in the array
 
 @return A sorted copy of the array
 */
- (NSArray<ObjectType> *)sort;

/**
 Sorts the array using the the default comparator on the given key

 @return A sorted copy of the array
 */
- (NSArray<ObjectType> *)sortBy:(NSString*)key;

- (NSArray<ObjectType> *)sortByKeyPaths:(NSArray<NSString *> *)keyPaths;

/**
 Alias for reverseObjectEnumerator.allObjects
 
 Returns a reversed array
 */
- (NSArray<ObjectType> *)reverse;

/**
 Return all the objects that are in both self and `array`.
 Alias for Ruby's & operator

 @return An array of objects common to both arrays
 */

- (NSArray<ObjectType> *)intersectionWithArray:(NSArray<ObjectType> *)array;

/**
 Return all the objects that in both self and `array` combined.
 Alias for Ruby's | operator

 @return An array of the two arrays combined
 */

- (NSArray<ObjectType> *)unionWithArray:(NSArray<ObjectType> *)array;

/**
 Return all the objects in self that are not in `array`.
 Alias for Ruby's - operator

 @return An array of the self without objects in `array`
 */

- (NSArray<ObjectType> *)relativeComplement:(NSArray<ObjectType> *)array;

/**
 Return all the objects that are unique to each array individually
 Alias for Ruby's ^ operator. Equivalent of a - b | b - a

 @return An array of elements which are in either of the arrays and not in their intersection.
 */

- (NSArray<ObjectType> *)symmetricDifference:(NSArray<ObjectType> *)array;

- (NSArray<ObjectType> *)filteredArrayByDistinctValuesOfKeyPath:(NSString *)keyPath;

- (NSArray<ObjectType> *)arrayByRemovingObject:(id)anObject;
- (NSArray<ObjectType> *)arrayByRemovingObjectsFromArray:(NSArray<ObjectType> *)otherArray;

- (NSArray *)distinctValuesForKeyPath:(NSString *)keyPath;
- (NSArray *)flattenedValuesForKeyPath:(NSString *)keyPath;
- (NSArray *)distinctFlattenedValuesForKeyPath:(NSString *)keyPath;
- (NSArray *)nonNullValuesForKeyPath:(NSString *)keyPath;
- (NSArray *)sortedValuesForKeyPath:(NSString *)keyPath;

- (NSArray<ObjectType> *)distinctFlatten;
- (NSArray<ObjectType> *)filterNull;
- (NSArray *)flatMap:(id (^)(ObjectType object))block;
- (NSArray *)distinctFlatMap:(id (^)(ObjectType object))block;

- (BOOL)containsArray:(NSArray<ObjectType> *)array;

@end


@class NSOrderedDictionaryKey;

@interface NSArray<__covariant ObjectType> (Grouping)

- (NSDictionary<__kindof id<NSCopying>, NSArray<ObjectType> *> *)groupBy:(NSString *)keyPath;
- (NSDictionary<NSString *, NSArray<__kindof NSObject *> *> *)groupByStringIDsInArrayAtKeypath:(NSString *)keyPath;
- (NSDictionary<__kindof id<NSCopying>, NSNumber *> *)groupWithCountedValuesBy:(NSString *)keyPath;

/** Like groupBy, but only assigns one value to a calculated key, so the result can be used as a lookup-map; multiple lookup-keys per array-elem are explicitely allowed */
- (NSDictionary<__kindof id<NSCopying>, __kindof NSObject *> *)lookupDictionaryByKeyPath:(NSString *)keyPath;

- (NSDictionary<NSOrderedDictionaryKey *, NSArray<ObjectType> *> *)groupOrderedBy:(NSString *)keyPath;
- (NSDictionary <__kindof id<NSCopying>, NSArray<ObjectType> *> *)groupWithDistinctValuesBy:(NSString *)keyPath;

@end

@interface NSOrderedDictionaryKey : NSObject<NSCopying>

@property (nonatomic, strong, readonly) id<NSCopying, NSObject> key;
@property (nonatomic, assign, readonly) NSUInteger index;

- (instancetype)initWithKey:(id<NSCopying, NSObject>)key index:(NSUInteger)index NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

/** Creates an array of numbers calculated from the given range. Array[0] = range.location; Array[1] = range.location + 1, ..., Array.lastObject = range.location + range.length - 1 */
extern NSArray *NSRangeToArray(NSRange range);

NS_ASSUME_NONNULL_END
