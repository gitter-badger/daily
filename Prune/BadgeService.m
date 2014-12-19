#import "BadgeService.h"
#import "TodoEvent.h"

@implementation BadgeService

- (void)updateBadge:(UIApplication *)application
{
    NSDate *startDate = [NSDate date];
    NSDate *endDate = [NSDate date];
    NSArray *todoEvents = [TodoEvent findAllIncompleteWithStartDate:startDate endDate:endDate];
    application.applicationIconBadgeNumber = todoEvents.count;
}

@end
