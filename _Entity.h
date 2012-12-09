// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Entity.h instead.

#import <CoreData/CoreData.h>


extern const struct EntityAttributes {
	 __unsafe_unretained NSString *subject1;
	 __unsafe_unretained NSString *subject2;
	 __unsafe_unretained NSString *subject3;
     __unsafe_unretained NSString *subject4;
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





@property (nonatomic, retain) NSString* subject1;



//- (BOOL)validateSubject1:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* subject2;



//- (BOOL)validateSubject2:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* subject3;



//- (BOOL)validateSubject3:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) NSString* subject4;



//- (BOOL)validateSubject4:(id*)value_ error:(NSError**)error_;






@end

@interface _Entity (CoreDataGeneratedAccessors)

@end

@interface _Entity (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveSubject1;
- (void)setPrimitiveSubject1:(NSString*)value;




- (NSString*)primitiveSubject2;
- (void)setPrimitiveSubject2:(NSString*)value;




- (NSString*)primitiveSubject3;
- (void)setPrimitiveSubject3:(NSString*)value;




- (NSString*)primitiveSubject4;
- (void)setPrimitiveSubject4:(NSString*)value;




@end
