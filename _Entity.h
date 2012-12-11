// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Entity.h instead.

#import <CoreData/CoreData.h>


extern const struct EntityAttributes {
	__unsafe_unretained NSString *date;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *qid;
	__unsafe_unretained NSString *subject1;
	__unsafe_unretained NSString *subject2;
	__unsafe_unretained NSString *subject3;
	__unsafe_unretained NSString *subject4;
	__unsafe_unretained NSString *uid;
	__unsafe_unretained NSString *voteblue;
	__unsafe_unretained NSString *votegreen;
} EntityAttributes;

extern const struct EntityRelationships {
} EntityRelationships;

extern const struct EntityFetchedProperties {
} EntityFetchedProperties;













@interface EntityID : NSManagedObjectID {}
@end

@interface _Entity : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (EntityID*)objectID;




@property (nonatomic, retain) NSDate* date;


//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString* qid;


//- (BOOL)validateQid:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString* subject1;


//- (BOOL)validateSubject1:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString* subject2;


//- (BOOL)validateSubject2:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString* subject3;


//- (BOOL)validateSubject3:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString* subject4;


//- (BOOL)validateSubject4:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString* uid;


//- (BOOL)validateUid:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber* voteblue;


@property int32_t voteblueValue;
- (int32_t)voteblueValue;
- (void)setVoteblueValue:(int32_t)value_;

//- (BOOL)validateVoteblue:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber* votegreen;


@property int32_t votegreenValue;
- (int32_t)votegreenValue;
- (void)setVotegreenValue:(int32_t)value_;

//- (BOOL)validateVotegreen:(id*)value_ error:(NSError**)error_;






@end

@interface _Entity (CoreDataGeneratedAccessors)

@end

@interface _Entity (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveQid;
- (void)setPrimitiveQid:(NSString*)value;




- (NSString*)primitiveSubject1;
- (void)setPrimitiveSubject1:(NSString*)value;




- (NSString*)primitiveSubject2;
- (void)setPrimitiveSubject2:(NSString*)value;




- (NSString*)primitiveSubject3;
- (void)setPrimitiveSubject3:(NSString*)value;




- (NSString*)primitiveSubject4;
- (void)setPrimitiveSubject4:(NSString*)value;




- (NSString*)primitiveUid;
- (void)setPrimitiveUid:(NSString*)value;




- (NSNumber*)primitiveVoteblue;
- (void)setPrimitiveVoteblue:(NSNumber*)value;

- (int32_t)primitiveVoteblueValue;
- (void)setPrimitiveVoteblueValue:(int32_t)value_;




- (NSNumber*)primitiveVotegreen;
- (void)setPrimitiveVotegreen:(NSNumber*)value;

- (int32_t)primitiveVotegreenValue;
- (void)setPrimitiveVotegreenValue:(int32_t)value_;




@end
