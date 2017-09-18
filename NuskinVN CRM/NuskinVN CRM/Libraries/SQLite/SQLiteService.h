//
//  SQLiteService.h
//
//  Created by luongnguyen on 1/23/13.
//  Copyright (c) 2013 luongnguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

#define str(fmt,...)                                [NSString stringWithFormat:fmt,##__VA_ARGS__]

@class SQLiteManager;
@interface SQLiteService : NSObject
{
    dispatch_queue_t queueWork;
    
    SQLiteManager* sqlMgr;
    NSString* currentDatabasePath;
    
    NSMutableDictionary* schemeTables; //tbName -> [columns]
}

#pragma mark MAIN
@property (nonatomic,strong) NSMutableDictionary* dbChangeLog; //tableName -> {last_change,}

- (void) useDatabase:(NSString*)path;

- (void) executeQueryAsync:(NSString*)query onDone:(void(^)(id))onDone;

- (void) selectFromTable:(NSString*)tbName withCondition:(NSString*)cond onDone:(void(^)(NSArray* results))onDone;
- (void) updateChanges:(id)changes toTable:(NSString*)tbName;
- (void) updateChanges:(id)changes toTable:(NSString*)tbName onBeforeQuery:(NSString*(^)(NSString*))onBeforQuery;

- (void) insertChanges:(id)changes toTable:(NSString*)tbName;
- (void) deleteWithDetail:(id)detail toTable:(NSString*)tbName;

- (void) closeDatabase;

- (void) updateSchemeTable:(NSString*)tbName onDone:(void(^)(id))onDone;
@end
