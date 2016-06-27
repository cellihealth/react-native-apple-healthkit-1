//
//  RCTAppleHealthKit+TypesAndPermissions.m
//  RCTAppleHealthKit
//
//  Created by Greg Wilson on 2016-06-26.
//  Copyright © 2016 Greg Wilson. All rights reserved.
//

#import "RCTAppleHealthKit+TypesAndPermissions.h"

@implementation RCTAppleHealthKit (TypesAndPermissions)

#pragma mark - HealthKit Permissions

- (NSDictionary *)readPermsDict {
    NSDictionary *readPerms = @{
        @"DietaryEnergy" : [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed],
        @"ActiveEnergy" : [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned],

        @"Height" : [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight],
        @"Weight" : [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass],
        @"BodyFatPercentage" : [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyFatPercentage],
        @"BodyMassIndex" : [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex],
        @"LeanBodyMass" : [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierLeanBodyMass],

        @"Steps" : [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
        @"DateOfBirth" : [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth],
        @"Sex" : [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex],
    };
    return readPerms;
}

- (NSDictionary *)writePermsDict {
    NSDictionary *writePerms = @{
        @"DietaryEnergy" : [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed],
        @"ActiveEnergy" : [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned],

        @"Height" : [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight],
        @"Weight" : [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass],
        @"BodyFatPercentage" : [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyFatPercentage],
        @"BodyMassIndex" : [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex],
        @"LeanBodyMass" : [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierLeanBodyMass],
    };
    return writePerms;
}


// Returns HealthKit read permissions from options array
- (NSSet *)getReadPermsFromOptions:(NSArray *)options {
    NSDictionary *readPermDict = [self readPermsDict];
    NSMutableSet *readPermSet = [NSMutableSet setWithCapacity:1];
    
    for(int i=0; i<[options count]; i++) {
        NSString *optionKey = options[i];
        HKObjectType *val = [readPermDict objectForKey:optionKey];
        if(val != nil) {
            RCTLogInfo(@"Adding read permissions from options: %@", optionKey);
            [readPermSet addObject:val];
        }
    }
    
    return readPermSet;
}


// Returns HealthKit write permissions from options array
- (NSSet *)getWritePermsFromOptions:(NSArray *)options {
    NSDictionary *writePermDict = [self writePermsDict];
    NSMutableSet *writePermSet = [NSMutableSet setWithCapacity:1];
    
    for(int i=0; i<[options count]; i++) {
        NSString *optionKey = options[i];
        HKObjectType *val = [writePermDict objectForKey:optionKey];
        if(val != nil) {
            RCTLogInfo(@"Adding write permissions from options: %@", optionKey);
            [writePermSet addObject:val];
        }
    }
    
    return writePermSet;
}

@end