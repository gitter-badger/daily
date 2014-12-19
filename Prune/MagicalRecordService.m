#import "MagicalRecordService.h"

@implementation MagicalRecordService

#pragma mark - Application Delegate

- (void)setup
{
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"MR"];
}

- (void)clean
{
    [MagicalRecord cleanUp];
}

@end
