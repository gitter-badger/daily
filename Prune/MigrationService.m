#import "MTMigration.h"
#import "MigrationService.h"
#import "Calendar.h"
#import "EKCalendar+VFDaily.h"
#import "Todo+VFDaily.h"

@implementation MigrationService

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    return _sharedInstance;
}

#pragma mark - Application Delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MTMigration migrateToBuild:@"1.0.6" block:^{
        [self migrateSelectedCalendarsFromUserDefaults];
        [Todo migrateFromTodoIdentifiers];
    }];
    return YES;
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
