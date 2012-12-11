// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Entity.m instead.

#import "_Entity.h"

const struct EntityAttributes EntityAttributes = {
	.date = @"date",
	.name = @"name",
	.qid = @"qid",
	.subject1 = @"subject1",
	.subject2 = @"subject2",
	.subject3 = @"subject3",
	.subject4 = @"subject4",
	.uid = @"uid",
	.voteblue = @"voteblue",
	.votegreen = @"votegreen",
	.votekind = @"votekind",
};

const struct EntityRelationships EntityRelationships = {
};

const struct EntityFetchedProperties EntityFetchedProperties = {
};

@implementation EntityID
@end

@implementation _Entity

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Entity" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Entity";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:moc_];
}

- (EntityID*)objectID {
	return (EntityID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"voteblueValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"voteblue"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"votegreenValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"votegreen"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic date;






@dynamic name;






@dynamic qid;






@dynamic subject1;






@dynamic subject2;






@dynamic subject3;






@dynamic subject4;






@dynamic uid;






@dynamic voteblue;



- (int32_t)voteblueValue {
	NSNumber *result = [self voteblue];
	return [result intValue];
}

- (void)setVoteblueValue:(int32_t)value_ {
	[self setVoteblue:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveVoteblueValue {
	NSNumber *result = [self primitiveVoteblue];
	return [result intValue];
}

- (void)setPrimitiveVoteblueValue:(int32_t)value_ {
	[self setPrimitiveVoteblue:[NSNumber numberWithInt:value_]];
}





@dynamic votegreen;



- (int32_t)votegreenValue {
	NSNumber *result = [self votegreen];
	return [result intValue];
}

- (void)setVotegreenValue:(int32_t)value_ {
	[self setVotegreen:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveVotegreenValue {
	NSNumber *result = [self primitiveVotegreen];
	return [result intValue];
}

- (void)setPrimitiveVotegreenValue:(int32_t)value_ {
	[self setPrimitiveVotegreen:[NSNumber numberWithInt:value_]];
}





@dynamic votekind;











@end
