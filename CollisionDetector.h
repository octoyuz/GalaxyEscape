//
//  CollisionDetector.h
//  Galaxy_Escape
//
//  Created by Tony on 3/1/13.
//  Copyright (c) 2013 USC. All rights reserved.
//

#import "Box2D.h"
#import <vector>
#import <algorithm>

struct CollisionData {
    b2Fixture *fixtureA;
    b2Fixture *fixtureB;
    bool operator==(const CollisionData& other) const{
        return (fixtureA == other.fixtureA) && (fixtureB == other.fixtureB);
    }
};
    
    class CollisionDetector : public b2ContactListener {
        
    public:
        std::vector<CollisionData> collisions;
        
        CollisionDetector();
        ~CollisionDetector();
        
        virtual void BeginContact(b2Contact* contact);
        virtual void EndContact(b2Contact* contact);
        virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
        virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
        
    };
