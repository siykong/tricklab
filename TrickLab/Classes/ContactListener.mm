//
//  ContactListener.m
//  TrickLab
//
//  Created by Siyao Kong on 3/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactListener.h"
#import "cocos2d.h"
#import "BabyHamster.h"
#import "Pipe.h"
#import "Owl.h"
#import "PhysicsObject.h"
#import "SimpleAudioEngine.h"

#define SFX_PIPE @"pipe.mp3"


void ContactListener::BeginContact(b2Contact *contact)
{
    b2Body *bodyA = contact->GetFixtureA()->GetBody();
    b2Body *bodyB = contact->GetFixtureB()->GetBody();
    
    PhysicsObject *objA = (PhysicsObject *)bodyA->GetUserData();
    PhysicsObject *objB = (PhysicsObject *)bodyB->GetUserData();
    
    NSString *objTypeA = objA.objId;
    NSString *objTypeB = objB.objId;
    
    CCLOG(@"============contactA:%@",objTypeA);
    CCLOG(@"============contactB:%@",objTypeB);
    
    if (([objTypeA isEqualToString:@"BABYHAMSTER"] && [objTypeB isEqualToString:@"PIPE"])|| ([objTypeB isEqualToString:@"BABYHAMSTER"] && [objTypeA isEqualToString:@"PIPE"])) {

        BabyHamster *babyHamster;
        if ([objTypeA isEqualToString:@"BABYHAMSTER"] && [objTypeB isEqualToString:@"PIPE"]) {
            babyHamster = (BabyHamster *)objA;
        }       
        else {
            babyHamster = (BabyHamster *)objB;
        }                        
            
        //set flag & play pipe sfx
        if (!babyHamster.contactWithPipe) {
            CCLOG(@"=========pipesfx");
            babyHamster.contactWithPipe = YES;
            babyHamster.vulnerableToOwl = NO;
            [[SimpleAudioEngine sharedEngine] playEffect:SFX_PIPE];            
        }                   
    }     
}

void ContactListener::EndContact(b2Contact *contact)
{
    b2Body *bodyA = contact->GetFixtureA()->GetBody();
    b2Body *bodyB = contact->GetFixtureB()->GetBody();
    
    PhysicsObject *objA = (PhysicsObject *)bodyA->GetUserData();
    PhysicsObject *objB = (PhysicsObject *)bodyB->GetUserData();
    
    NSString *objTypeA = objA.objId;
    NSString *objTypeB = objB.objId;
    
    if (([objTypeA isEqualToString:@"BABYHAMSTER"] && [objTypeB isEqualToString:@"PIPE"])|| ([objTypeB isEqualToString:@"BABYHAMSTER"] && [objTypeA isEqualToString:@"PIPE"])) {
        
        BabyHamster *babyHamster;
        if ([objTypeA isEqualToString:@"BABYHAMSTER"] && [objTypeB isEqualToString:@"PIPE"]) 
            babyHamster = (BabyHamster *)objA;
        else
            babyHamster = (BabyHamster *)objB;            
        
        //set flag
        babyHamster.contactWithPipe = NO;
        babyHamster.vulnerableToOwl = YES;                   
    }
}
