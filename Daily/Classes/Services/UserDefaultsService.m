#import "UserDefaultsService.h"

@implementation UserDefaultsService

- (void)save
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
