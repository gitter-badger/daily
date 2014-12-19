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
}

@end
