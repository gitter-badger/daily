#import "MTMigration.h"
#import "MigrationService.h"
#import "Calendar.h"
#import "EKCalendar+VFDaily.h"
#import "Todo+VFDaily.h"

@implementation MigrationService

- (void)run
{
    [MTMigration migrateToBuild:@"1.0.6" block:^{
        [self migrateSelectedCalendarsFromUserDefaults];
        [Todo migrateFromTodoIdentifiers];
    }];
    
    [MTMigration migrateToBuild:@"1.0.8" block:^{
        [Todo migrateFromTimeToNoneTime];
    }];
    
    [MTMigration migrateToBuild:@"1.0.10" block:^{
        [self migrateSelectedCalendarsWhenNoneSelected];
    }];
}

#pragma mark - Private

- (void)migrateSelectedCalendarsFromUserDefaults
{
    NSArray *selectedCalendarIdentifiers = [[NSUserDefaults standardUserDefaults] objectForKey:@"calendarIdentifiers"];
    NSArray *calendars = [EKCalendar calendarForEntityType:EKEntityTypeEvent];
    [calendars enumerateObjectsUsingBlock:^(EKCalendar *calendar, NSUInteger idx, BOOL *stop) {
        if ([selectedCalendarIdentifiers containsObject:calendar.calendarIdentifier]) {
            calendar.enabledDate = [NSDate date];
        } else {
            calendar.enabledDate = nil;
        }
    }];
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
}

- (void)migrateSelectedCalendarsWhenNoneSelected
{
    NSMutableArray *disabledCalendars = [NSMutableArray array];
    NSArray *calendars = [EKCalendar calendarForEntityType:EKEntityTypeEvent];
    [calendars enumerateObjectsUsingBlock:^(EKCalendar *calendar, NSUInteger idx, BOOL *stop) {
        if (!calendar.enabledDate) {
            [disabledCalendars addObject:calendar];
        }
    }];
    if ([disabledCalendars isEqualToArray:calendars]) {
        [calendars enumerateObjectsUsingBlock:^(EKCalendar *calendar, NSUInteger idx, BOOL *stop) {
            calendar.enabledDate = [NSDate date];
        }];
    }
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
}

@end
