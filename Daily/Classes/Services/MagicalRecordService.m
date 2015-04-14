#import "MagicalRecordService.h"

@implementation MagicalRecordService

#pragma mark - Application Delegate

- (void)setup
{
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"MagicalRecord"];
}

- (void)clean
{
    [MagicalRecord cleanUp];
}

@end
