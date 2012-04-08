//
//  ContactListener.h
//  TrickLab
//
//  Created by Siyao Kong on 3/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Box2D.h"

class ContactListener : public b2ContactListener 
{
    private:
        void BeginContact(b2Contact *contact);
        void EndContact(b2Contact *contact);    
};  