//
//  SQLiteService.m
//
//  Created by luongnguyen on 1/23/13.
//  Copyright (c) 2013 luongnguyen. All rights reserved.
//

#import "LibUtil.h"

#import "NSString+Wrapper.h"

#import "SQLiteManager.h"

#import "SQLiteService.h"

@interface SQLiteService (Private)
- (void) executeQuery:(NSString*)query andOnDone:(void(^)(id))onDone andOnError:(void(^)(id))onError;
- (id) executeQuery:(NSString *)query;
- (void) executeQueries:(NSArray*)queries andOnDone:(void(^)(id))onDone andOnError:(void(^)(id))onError;
- (id) executeQueries:(NSArray*)queries;

@end

@implementation SQLiteService

#pragma mark INIT
- (id) init
{
    self = [super init];
    if (self)
    {
        sqlMgr = [[SQLiteManager alloc] init];
        
        queueWork = dispatch_queue_create("SQLiteService.Work", 0);
        
        self.dbChangeLog = [[NSMutableDictionary alloc] init];
        
        schemeTables = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark MAIN
- (void) useDatabase:(NSString*)path
{
    currentDatabasePath = path;
    sqlMgr.databasePath = path;
}

- (void) executeQueryAsync:(NSString*)query onDone:(void(^)(id))onDone
{
    [LibUtil execToQueue:queueWork block:^{
        NSArray* arr = [self executeQuery:query];
        [LibUtil execBlockMainThread:^{
            if (onDone) onDone(arr);            
        }];
    }];
}

- (void) selectFromTable:(NSString*)tbName withCondition:(NSString*)cond onDone:(void(^)(NSArray* results))onDone
{
    NSString* query = str(@"Select * from %@ where %@",tbName,cond);
    
    if ([query hasSuffix:@" where "]) //empty condition
    {
        query = [query substringToIndex:query.length-7];
    }
    
    [LibUtil execToQueue:queueWork block:^{
        
        NSArray* res = [self executeQuery:query];
        for (NSMutableDictionary* d in res)
        {
            for (NSString* k in d.allKeys)
            {
                id value = [d objectForKey:k];
                if ([value isKindOfClass:[NSString class]])
                {
                    value = [((NSString*)value) unescapeQuotes];
                    [d setObject:value forKey:k];
                }
            }
        }
        
        [LibUtil execBlockMainThread:^{
            if (onDone) onDone(res);
        }];
    }];
}

- (void) updateChanges:(id)changes toTable:(NSString*)tbName
{
    [self.dbChangeLog setObject:@{@"last_change":[NSDate date]} forKey:tbName];
    NSArray* lstValidNames = [schemeTables objectForKey:tbName];
    if (!lstValidNames || lstValidNames.count == 0)
    {
        [self updateSchemeTable:tbName onDone:^(id back){
            [self updateChanges:changes toTable:tbName];
        }];
        return;
    }
    
    NSMutableArray* lstQuery = [NSMutableArray array];
    NSArray* lst = nil;
    if ([changes isKindOfClass:[NSArray class]])
        lst = changes;
    else
        lst = @[changes];
    
    for (id obj in lst)
    {
        NSString* query = @"Update %@ set %@ where %@";
        
        NSString* qf = @"";
        NSString* qc = @"";
        
        for (NSString* key in [obj allKeys])
        {
            if (![key hasPrefix:@"$"] && ![lstValidNames containsObject:key])
            {
                NSLog(@"WARNING : column %@ not found",key);
                continue;
            }

            id value = [obj objectForKey:key];
            BOOL isStringType = [value isKindOfClass:[NSString class]];
            BOOL isNumberType = [value isKindOfClass:[NSNumber class]];

            if ([value isKindOfClass:[NSNull class]]) value = @"null";
            
            if (isStringType)
            {
                value = [((NSString*)value) escapeQuotes];
            }
            
            if (![key hasPrefix:@"$"])
            {
                if (isStringType) qf = [qf stringByAppendingFormat:@", %@='%@'",key,value];
                else qf = [qf stringByAppendingFormat:@", %@=%@",key,value];
            }
            else //condition part
            {
                NSString* kk = [key substringFromIndex:1];
                if (isStringType) qc = [qc stringByAppendingFormat:@" and %@='%@'",kk,value];
                else if (isNumberType) qc = [qc stringByAppendingFormat:@" and %@=%@",kk,value];
            }
        }
        
        if (qf.length > 0) qf = [qf substringFromIndex:1];
        if (qc.length > 0) qc = [qc substringFromIndex:4];
        
        query = [NSString stringWithFormat:query,tbName,qf,qc];
            
        [lstQuery addObject:query];
    }
    
//    NLog(@"%@",lstQuery);
    
    [LibUtil execToQueue:queueWork block:^{
        [self executeQueries:lstQuery];
    }];
    
}

- (void) updateChanges:(id)changes toTable:(NSString*)tbName onBeforeQuery:(NSString*(^)(NSString*))onBeforQuery
{
    [self.dbChangeLog setObject:@{@"last_change":[NSDate date]} forKey:tbName];
    NSArray* lstValidNames = [schemeTables objectForKey:tbName];
    if (!lstValidNames || lstValidNames.count == 0)
    {
        [self updateSchemeTable:tbName onDone:^(id back){
            [self updateChanges:changes toTable:tbName];
        }];
        return;
    }
    
    NSMutableArray* lstQuery = [NSMutableArray array];
    NSArray* lst = nil;
    if ([changes isKindOfClass:[NSArray class]])
        lst = changes;
    else
        lst = @[changes];
    
    for (id obj in lst)
    {
        NSString* query = @"Update %@ set %@ where %@";
        
        NSString* qf = @"";
        NSString* qc = @"";
        
        for (NSString* key in [obj allKeys])
        {
            if (![key hasPrefix:@"$"] && ![lstValidNames containsObject:key])
            {
                NSLog(@"WARNING : column %@ not found",key);
                continue;
            }
            
            id value = [obj objectForKey:key];
            BOOL isStringType = [value isKindOfClass:[NSString class]];
            BOOL isNumberType = [value isKindOfClass:[NSNumber class]];
            
            if ([value isKindOfClass:[NSNull class]]) value = @"null";
            
            if (isStringType)
            {
                value = [((NSString*)value) escapeQuotes];
            }
            
            if (![key hasPrefix:@"$"])
            {
                if (isStringType) qf = [qf stringByAppendingFormat:@", %@='%@'",key,value];
                else qf = [qf stringByAppendingFormat:@", %@=%@",key,value];
            }
            else //condition part
            {
                NSString* kk = [key substringFromIndex:1];
                if (isStringType) qc = [qc stringByAppendingFormat:@" and %@='%@'",kk,value];
                else if (isNumberType) qc = [qc stringByAppendingFormat:@" and %@=%@",kk,value];
            }

        }
        
        if (qf.length > 0) qf = [qf substringFromIndex:1];
        if (qc.length > 0) qc = [qc substringFromIndex:3];
        
        query = [NSString stringWithFormat:query,tbName,qf,qc];
        
        //give a chance to refine query
        if (onBeforQuery)
        {
            query = onBeforQuery(query);
        }
        
        //...
        [lstQuery addObject:query];
    }
    
    //    NLog(@"%@",lstQuery);
    [LibUtil execToQueue:queueWork block:^{
        [self executeQueries:lstQuery];
    }];
    
}

- (void) insertChanges:(id)changes toTable:(NSString*)tbName
{
    [self.dbChangeLog setObject:@{@"last_change":[NSDate date]} forKey:tbName];

    NSArray* lstValidNames = [schemeTables objectForKey:tbName];
    if (!lstValidNames || lstValidNames.count == 0)
    {
        [self updateSchemeTable:tbName onDone:^(id back){
            [self insertChanges:changes toTable:tbName];
        }];
        return;
    }
    
    NSMutableArray* lstQuery = [NSMutableArray array];
    NSArray* lst = nil;
    if ([changes isKindOfClass:[NSArray class]])
        lst = changes;
    else
        lst = @[changes];
    
    for (id obj in lst)
    {
        NSString* query = @"Insert into %@(%@) values(%@)";
        
        NSString* qf = @"";
        NSString* qfK = @"";
        
        for (NSString* key in [obj allKeys])
        {
            if (![key hasPrefix:@"$"] && ![lstValidNames containsObject:key])
            {
                NSLog(@"WARNING : column %@ not found",key);
                continue;
            }
            
            id value = [obj objectForKey:key];
            if ([value isKindOfClass:[NSNull class]]) continue;
            
            if ([value isKindOfClass:[NSString class]])
            {
                NSString* strValue = value;
                qf = [qf stringByAppendingFormat:@", '%@'",[strValue escapeQuotes]];
                qfK = [qfK stringByAppendingFormat:@", %@",key];
            }
            else if ([value isKindOfClass:[NSNumber class]])
            {
                qf = [qf stringByAppendingFormat:@", %@",value];
                qfK = [qfK stringByAppendingFormat:@", %@",key];
            }
        }
        
        if (qf.length > 0) qf = [qf substringFromIndex:1];
        if (qfK.length > 0) qfK = [qfK substringFromIndex:1];
        
        query = [NSString stringWithFormat:query,tbName,qfK,qf];
        
        [lstQuery addObject:query];
    }
    
//    NLog(@"INSERT : %@",lstQuery);
    [LibUtil execToQueue:queueWork block:^{
        [self executeQueries:lstQuery];
    }];

}

- (void) deleteWithDetail:(id)detail toTable:(NSString*)tbName
{
    [self.dbChangeLog setObject:@{@"last_change":[NSDate date]} forKey:tbName];

    NSMutableArray* lstQuery = [NSMutableArray array];
    NSArray* lst = nil;
    if ([detail isKindOfClass:[NSArray class]])
        lst = detail;
    else
        lst = @[detail];
    
    for (id obj in lst)
    {
        NSString* query = @"Delete from %@ where %@";
        
        NSString* qf = @"";
        NSString* qc = @"";
        
        for (NSString* key in [obj allKeys])
        {
            id value = [obj objectForKey:key];
            if ([value isKindOfClass:[NSNull class]]) value = @"";
            
            if ([value isKindOfClass:[NSString class]]) qc = [qc stringByAppendingFormat:@" and %@='%@'",key,value];
            else if ([value isKindOfClass:[NSNumber class]]) qc = [qc stringByAppendingFormat:@" and %@=%@",key,value];
        }
        
        if (qf.length > 0) qf = [qf substringFromIndex:4];
        if (qc.length > 0) qc = [qc substringFromIndex:4];
        
        query = [NSString stringWithFormat:query,tbName,qc];
        
        [lstQuery addObject:query];
    }

//    NLog(@"DELETE %@",lstQuery);
    [LibUtil execToQueue:queueWork block:^{
        [self executeQueries:lstQuery];
    }];
}

- (void) closeDatabase
{
    [sqlMgr closeDatabase];
}

- (void) updateSchemeTable:(NSString*)tbName onDone:(void(^)(id))onDone
{
    [LibUtil execToQueue:queueWork block:^{
        NSArray* arr = [sqlMgr getRowsForQuery:str(@"pragma table_info('%@');",tbName)];
        NSMutableArray* names = [NSMutableArray array];
        for (id d in arr)
        {
            [names addObject:[d objectForKey:@"name"]];
        }
        
        [LibUtil execBlockMainThread:^{
            [schemeTables setObject:names forKey:tbName];
            if (onDone) onDone(names);
        }];
    }];
}

#pragma mark PRIVATE
- (void) executeQuery:(NSString*)query andOnDone:(void(^)(id))onDone andOnError:(void(^)(id))onError
{
    if ([[query uppercaseString] hasPrefix:@"SELECT"])
    {
        NSArray* results =[sqlMgr getRowsForQuery:query];
        onDone(results);
    }
    else
    {
        NSError* err = [sqlMgr doQuery:query];
        if (!err)
        {
            onDone(nil);
        }
        else
        {
            onError(err);
        }
    }
}

- (id) executeQuery:(NSString *)query
{
    if ([[query uppercaseString] hasPrefix:@"SELECT"])
    {
        NSArray* results =[sqlMgr getRowsForQuery:query];
        return results;
    }
    else
    {
        NSError* err = [sqlMgr doQuery:query];
        if (!err)
        {
            return @"true";
        }
        else
        {
            return err;
        }
    }
}

- (void) executeQueries:(NSArray*)queries andOnDone:(void(^)(id))onDone andOnError:(void(^)(id))onError
{
    //not for select
    NSError* err = [sqlMgr doQueries:queries];
    if (err)
    {
        onError(err);
        return;
    }
    
    if (onDone) onDone(nil);
}

- (id) executeQueries:(NSArray*)queries
{
    NSError* err = [sqlMgr doQueries:queries];
    if (err)
    {
        return err;
    }
    return @"true";
}

@end
