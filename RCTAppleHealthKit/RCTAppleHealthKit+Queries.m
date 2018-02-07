//
//  RCTAppleHealthKit+Queries.m
//  RCTAppleHealthKit
//
//  Created by Greg Wilson on 2016-06-26.
//  Copyright © 2016 Greg Wilson. All rights reserved.
//

#import "RCTAppleHealthKit+Queries.h"
#import "RCTAppleHealthKit+Utils.h"
#import <Foundation/NSProcessInfo.h>

@implementation RCTAppleHealthKit (Queries)


- (void)fetchMostRecentQuantitySampleOfType:(HKQuantityType *)quantityType
                                  predicate:(NSPredicate *)predicate
                                 completion:(void (^)(HKQuantity *, NSDate *, NSDate *, NSError *))completion {

    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc]
            initWithKey:HKSampleSortIdentifierEndDate
              ascending:NO
    ];

    HKSampleQuery *query = [[HKSampleQuery alloc]
            initWithSampleType:quantityType
                     predicate:predicate
                         limit:1
               sortDescriptors:@[timeSortDescriptor]
                resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {

                      if (!results) {
                          if (completion) {
                              completion(nil, nil, nil, error);
                          }
                          return;
                      }

                      if (completion) {
                          // If quantity isn't in the database, return nil in the completion block.
                          HKQuantitySample *quantitySample = results.firstObject;
                          HKQuantity *quantity = quantitySample.quantity;
                          NSDate *startDate = quantitySample.startDate;
                          NSDate *endDate = quantitySample.endDate;
                          completion(quantity, startDate, endDate, error);
                      }
                }
    ];
    [self.healthStore executeQuery:query];
}


- (void)fetchQuantitySamplesOfType:(HKQuantityType *)quantityType
                              unit:(HKUnit *)unit
                         predicate:(NSPredicate *)predicate
                         ascending:(BOOL)asc
                             limit:(NSUInteger)lim
                        completion:(void (^)(NSArray *, NSError *))completion {

    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate
                                                                       ascending:asc];

    // declare the block
    void (^handlerBlock)(HKSampleQuery *query, NSArray *results, NSError *error);
    // create and assign the block
    handlerBlock = ^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }

        if (completion) {
            NSMutableArray *data = [NSMutableArray arrayWithCapacity:1];

            dispatch_async(dispatch_get_main_queue(), ^{

                for (HKQuantitySample *sample in results) {
                    HKQuantity *quantity = sample.quantity;
                    double value = [quantity doubleValueForUnit:unit];

                    NSString *startDateString = [RCTAppleHealthKit buildISO8601StringFromDate:sample.startDate];
                    NSString *endDateString = [RCTAppleHealthKit buildISO8601StringFromDate:sample.endDate];
                    NSString *bundleIdentifierAppSourceString = sample.sourceRevision.source.bundleIdentifier;

                    NSDictionary *elem = @{
                            @"value" : @(value),
                            @"startDate" : startDateString,
                            @"endDate" : endDateString,
                            @"bundleIdentifierAppSource" : bundleIdentifierAppSourceString,
                    };

                    [data addObject:elem];
                }

                completion(data, error);
            });
        }
    };

    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:quantityType
                                                           predicate:predicate
                                                               limit:lim
                                                     sortDescriptors:@[timeSortDescriptor]
                                                      resultsHandler:handlerBlock];

    [self.healthStore executeQuery:query];
}









- (void)fetchSleepCategorySamplesForPredicate:(NSPredicate *)predicate
                                   limit:(NSUInteger)lim
                                   completion:(void (^)(NSArray *, NSError *))completion {


    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate
                                                                       ascending:false];


    // declare the block
    void (^handlerBlock)(HKSampleQuery *query, NSArray *results, NSError *error);
    // create and assign the block
    handlerBlock = ^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }

        if (completion) {
            NSMutableArray *data = [NSMutableArray arrayWithCapacity:1];

            dispatch_async(dispatch_get_main_queue(), ^{

                for (HKCategorySample *sample in results) {

                    // HKCategoryType *catType = sample.categoryType;
                    NSInteger val = sample.value;

                    // HKQuantity *quantity = sample.quantity;
                    // double value = [quantity doubleValueForUnit:unit];

                    NSString *startDateString = [RCTAppleHealthKit buildISO8601StringFromDate:sample.startDate];
                    NSString *endDateString = [RCTAppleHealthKit buildISO8601StringFromDate:sample.endDate];
                    NSString *bundleIdentifierAppSourceString = sample.sourceRevision.source.bundleIdentifier;

                    NSString *valueString;

                    switch (val) {
                      case HKCategoryValueSleepAnalysisInBed:
                        valueString = @"INBED";
                      break;
                      case HKCategoryValueSleepAnalysisAsleep:
                        valueString = @"ASLEEP";
                      break;
                     default:
                        valueString = @"UNKNOWN";
                     break;
                  }

                    NSDictionary *elem = @{
                            @"value" : valueString,
                            @"startDate" : startDateString,
                            @"endDate" : endDateString,
                            @"bundleIdentifierAppSource" : bundleIdentifierAppSourceString,
                    };

                    [data addObject:elem];
                }

                completion(data, error);
            });
        }
    };

    // HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:quantityType
    //                                                        predicate:predicate
    //                                                            limit:lim
    //                                                  sortDescriptors:@[timeSortDescriptor]
    //                                                   resultsHandler:handlerBlock];

    HKCategoryType *categoryType =
    [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];

    // HKCategorySample *categorySample =
    // [HKCategorySample categorySampleWithType:categoryType
    //                                    value:value
    //                                startDate:startDate
    //                                  endDate:endDate];


   HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:categoryType
                                                          predicate:predicate
                                                              limit:lim
                                                    sortDescriptors:@[timeSortDescriptor]
                                                     resultsHandler:handlerBlock];


    [self.healthStore executeQuery:query];
}













- (void)fetchCorrelationSamplesOfType:(HKQuantityType *)quantityType
                                 unit:(HKUnit *)unit
                            predicate:(NSPredicate *)predicate
                            ascending:(BOOL)asc
                                limit:(NSUInteger)lim
                           completion:(void (^)(NSArray *, NSError *))completion {

    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate
                                                                       ascending:asc];

    // declare the block
    void (^handlerBlock)(HKSampleQuery *query, NSArray *results, NSError *error);
    // create and assign the block
    handlerBlock = ^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }

        if (completion) {
            NSMutableArray *data = [NSMutableArray arrayWithCapacity:1];

            dispatch_async(dispatch_get_main_queue(), ^{

                for (HKCorrelation *sample in results) {
                    NSString *startDateString = [RCTAppleHealthKit buildISO8601StringFromDate:sample.startDate];
                    NSString *endDateString = [RCTAppleHealthKit buildISO8601StringFromDate:sample.endDate];
                    NSString *bundleIdentifierAppSourceString = sample.sourceRevision.source.bundleIdentifier;

                    NSDictionary *elem = @{
                      @"correlation" : sample,
                      @"startDate" : startDateString,
                      @"endDate" : endDateString,
                      @"bundleIdentifierAppSource" : bundleIdentifierAppSourceString,
                    };
                    [data addObject:elem];
                }

                completion(data, error);
            });
        }
    };

    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:quantityType
                                                           predicate:predicate
                                                               limit:lim
                                                     sortDescriptors:@[timeSortDescriptor]
                                                      resultsHandler:handlerBlock];

    [self.healthStore executeQuery:query];
}


- (void)fetchSumOfSamplesTodayForType:(HKQuantityType *)quantityType
                                 unit:(HKUnit *)unit
                           completion:(void (^)(double, NSError *))completionHandler {

    NSPredicate *predicate = [RCTAppleHealthKit predicateForSamplesToday];
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:quantityType
                                                          quantitySamplePredicate:predicate
                                                          options:HKStatisticsOptionCumulativeSum
                                                          completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
                                                                HKQuantity *sum = [result sumQuantity];
                                                                if (completionHandler) {
                                                                    double value = [sum doubleValueForUnit:unit];
                                                                    completionHandler(value, error);
                                                                }
                                                          }];

    [self.healthStore executeQuery:query];
}


- (void)fetchSumOfSamplesOnDayForType:(HKQuantityType *)quantityType
                                 unit:(HKUnit *)unit
                                  day:(NSDate *)day
                           completion:(void (^)(double, NSDate *, NSDate *, NSError *))completionHandler {

    NSPredicate *predicate = [RCTAppleHealthKit predicateForSamplesOnDay:day];
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:quantityType
                                                          quantitySamplePredicate:predicate
                                                          options:HKStatisticsOptionCumulativeSum
                                                          completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
                                                              HKQuantity *sum = [result sumQuantity];
                                                              NSDate *startDate = result.startDate;
                                                              NSDate *endDate = result.endDate;
                                                              if (completionHandler) {
                                                                     double value = [sum doubleValueForUnit:unit];
                                                                     completionHandler(value,startDate, endDate, error);
                                                              }
                                                          }];

    [self.healthStore executeQuery:query];
}


- (void)fetchCumulativeSumStatisticsCollection:(HKQuantityType *)quantityType
                                          unit:(HKUnit *)unit
                                     startDate:(NSDate *)startDate
                                       endDate:(NSDate *)endDate
                                    completion:(void (^)(NSArray *, NSError *))completionHandler {

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 1;

    NSDateComponents *anchorComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                     fromDate:[NSDate date]];
    anchorComponents.hour = 0;
    NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];

    // Create the query
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType
                                                                           quantitySamplePredicate:nil
                                                                                           options:HKStatisticsOptionCumulativeSum
                                                                                        anchorDate:anchorDate
                                                                                intervalComponents:interval];

    // Set the results handler
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
        if (error) {
            // Perform proper error handling here
            NSLog(@"*** An error occurred while calculating the statistics: %@ ***",error.localizedDescription);
        }

        NSMutableArray *data = [NSMutableArray arrayWithCapacity:1];
        [results enumerateStatisticsFromDate:startDate
                                      toDate:endDate
                                   withBlock:^(HKStatistics *result, BOOL *stop) {

                                       HKQuantity *quantity = result.sumQuantity;
                                       if (quantity) {
                                           NSDate *date = result.startDate;
                                           double value = [quantity doubleValueForUnit:[HKUnit countUnit]];
                                           NSLog(@"%@: %f", date, value);

                                           NSString *dateString = [RCTAppleHealthKit buildISO8601StringFromDate:date];
                                           NSArray *elem = @[dateString, @(value)];
                                           [data addObject:elem];
                                       }
                                   }];
        NSError *err;
        completionHandler(data, err);
    };

    [self.healthStore executeQuery:query];
}


- (void)fetchCumulativeSumStatisticsCollection:(HKQuantityType *)quantityType
                                          unit:(HKUnit *)unit
                                     startDate:(NSDate *)startDate
                                       endDate:(NSDate *)endDate
                                     ascending:(BOOL)asc
                                         limit:(NSUInteger)lim
                                    completion:(void (^)(NSArray *, NSError *))completionHandler {

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 1;

    NSDateComponents *anchorComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                     fromDate:[NSDate date]];
    anchorComponents.hour = 0;
    NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];

    // Create the query
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType
                                                                           quantitySamplePredicate:nil
                                                                                           options:HKStatisticsOptionCumulativeSum
                                                                                        anchorDate:anchorDate
                                                                                intervalComponents:interval];

    // Set the results handler
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
        if (error) {
            // Perform proper error handling here
            NSLog(@"*** An error occurred while calculating the statistics: %@ ***", error.localizedDescription);
        }

        NSMutableArray *data = [NSMutableArray arrayWithCapacity:1];

        [results enumerateStatisticsFromDate:startDate
                                      toDate:endDate
                                   withBlock:^(HKStatistics *result, BOOL *stop) {

                                       HKQuantity *quantity = result.sumQuantity;
                                       if (quantity) {
                                           NSDate *startDate = result.startDate;
                                           NSDate *endDate = result.endDate;
                                           double value = [quantity doubleValueForUnit:unit];

                                           NSString *startDateString = [RCTAppleHealthKit buildISO8601StringFromDate:startDate];
                                           NSString *endDateString = [RCTAppleHealthKit buildISO8601StringFromDate:endDate];

                                           NSDictionary *elem = @{
                                                   @"value" : @(value),
                                                   @"startDate" : startDateString,
                                                   @"endDate" : endDateString,
                                           };
                                           [data addObject:elem];
                                       }
                                   }];
        // is ascending by default
        if(asc == false) {
            [RCTAppleHealthKit reverseNSMutableArray:data];
        }

        if((lim > 0) && ([data count] > lim)) {
            NSArray* slicedArray = [data subarrayWithRange:NSMakeRange(0, lim)];
            NSError *err;
            completionHandler(slicedArray, err);
        } else {
            NSError *err;
            completionHandler(data, err);
        }
    };

    [self.healthStore executeQuery:query];
}

// [Nanaz] fetchCumulativeSumStatisticsCollection with HKSampleQuery to getting the device info
- (void)fetchCumulativeSumStatisticsCollection:(HKSampleType *)sampleType
                                     predicate:(NSPredicate *)predicate
                                          unit:(HKUnit *)unit
                                     ascending:(BOOL)asc
                                         limit:(NSUInteger)lim
                                       groupBy:(NSString *)grpby
                                    completion:(void (^)(NSArray *, NSError *))completionHandler {

    NSLog(@"fetchCumulativeSumStatisticsCollection with HKSampleQuery with predicate: %@", [predicate predicateFormat]);

    NSString *endKey = HKSampleSortIdentifierEndDate;
    NSSortDescriptor *endDateSort = [NSSortDescriptor sortDescriptorWithKey:endKey ascending:asc];

    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:predicate limit:lim sortDescriptors:@[endDateSort] resultsHandler:^(HKSampleQuery *sampleQuery, NSArray *results, NSError *error) {
        if (error) {
            // Perform proper error handling here
            NSLog(@"*** An error occurred while calculating the statistics: %@ ***", error.localizedDescription);
        }

        NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:results.count];
        NSMutableDictionary *elema = [NSMutableDictionary dictionary];
        
        int group_by = 0;
        if ([grpby isEqualToString:@"endDate"]) {
            group_by = 1;
            NSLog(@"Group by: %@", grpby);
        } else {
            NSLog(@"Group by (default): startDate");
        }
        
        for (HKSample *sample in results) {
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"yyyy-MM-dd"];
            
            NSString *kDate;
            switch (group_by) {
            case 1:
                kDate = [format stringFromDate:sample.endDate]; break;
            default:
                kDate = [format stringFromDate:sample.startDate];
            }
    
//            NSDate *startDate = sample.startDate;
//            NSDate *endDate = sample.endDate;
//            NSString *startDateString = [RCTAppleHealthKit buildISO8601StringFromDate:startDate];
//            NSString *endDateString = [RCTAppleHealthKit buildISO8601StringFromDate:endDate];
//
//            NSMutableDictionary *elem = [NSMutableDictionary dictionary];
//
//            elem[@"startDate"] = startDateString;
//            elem[@"endDate"] = endDateString;
//            elem[@"sourceName"] = sample.sourceRevision.source.name;
//            elem[@"identifier"] = sample.sourceRevision.source.bundleIdentifier;
//            elem[@"device"] = sample.device.name;
//
//            HKQuantitySample *qsample = (HKQuantitySample *) sample;
//            [elem setValue:@([qsample.quantity doubleValueForUnit:unit]) forKey:@"value"];
//
//            [data addObject:elem];

            if(!elema[kDate]){
                [elema setObject:[NSMutableDictionary dictionary] forKey:kDate];
            }

            NSString *kDevice = [NSString alloc];

            if(sample.device.name){
                kDevice = sample.device.name;
            }else{
                kDevice = [sample.sourceRevision.source.name stringByReplacingOccurrencesOfString:@" " withString:@""];
            }

            if(!elema[kDate][kDevice]){
                [elema[kDate] setObject:[NSMutableDictionary dictionary] forKey:kDevice];
                elema[kDate][kDevice][@"date"] = kDate;
                elema[kDate][kDevice][@"sourceName"] = sample.sourceRevision.source.name;
                elema[kDate][kDevice][@"identifier"] = sample.sourceRevision.source.bundleIdentifier;
                elema[kDate][kDevice][@"device"] = kDevice;
                elema[kDate][kDevice][@"value"] = @"0";
            }

            HKQuantitySample *qsample = (HKQuantitySample *) sample;

            [elema[kDate][kDevice] setValue:@([qsample.quantity doubleValueForUnit:unit] + [elema[kDate][kDevice][@"value"] doubleValue]) forKey:@"value"];
        }

        for(NSString *kDate in elema){
            for(NSString *kDevice in elema[kDate]){
                [data addObject:elema[kDate][kDevice]];
            }
        }
        
        if(asc == false) {
            [RCTAppleHealthKit reverseNSMutableArray:data];
        }

        if(lim > 0) {
            NSArray* slicedArray = [data subarrayWithRange:NSMakeRange(0, lim)];
            NSError *err;
            completionHandler(slicedArray, err);
        } else {
            NSError *err;
            completionHandler(data, err);
        }
        
        if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-NSLogger"]) {
            NSLog(@"data: %@", data);
        }
    }];

    [self.healthStore executeQuery:query];
}

@end
