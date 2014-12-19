#import "BadgeService.h"
#import "TodoEvent.h"

@implementation BadgeService

- (void)updateBadge:(UIApplication *)application
{
    NSDate *startDate = [[NSDate date] morning];
    NSDate *endDate = [[NSDate date] night];
    NSArray *todoEvents = [TodoEvent findAllIncompleteWithStartDate:startDate endDate:endDate];
    application.applicationIconBadgeNumber = todoEvents.count;
}

@end
