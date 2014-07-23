//
//  Palette.h
//  colordot-ios
//
//  Created by Colin on 7/18/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Palette : NSManagedObject

@property (nonatomic, retain) NSDate *created;
@property (nonatomic, retain) NSSet *colors;

@end

@interface Palette (CoreDataGeneratedAccessors)

- (void)addColorsObject:(NSManagedObject *)value;
- (void)removeColorsObject:(NSManagedObject *)value;
- (void)addColors:(NSSet *)values;
- (void)removeColors:(NSSet *)values;

@end
