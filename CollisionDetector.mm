//
//  CollisionDetector.m
//  Galaxy_Escape
//
//  Created by Tony on 3/1/13.
//  Copyright (c) 2013 USC. All rights reserved.
//

#import "CollisionDetector.h"

CollisionDetector::CollisionDetector() : collisions() {
}

CollisionDetector::~CollisionDetector() {
}

void CollisionDetector::BeginContact(b2Contact* contact) {
    // We need to copy out the data because the b2Contact passed in
    // is reused.
    CollisionData myCollision = { contact->GetFixtureA(), contact->GetFixtureB() };
    collisions.push_back(myCollision);
}

void CollisionDetector::EndContact(b2Contact* contact) {
    CollisionData myCollision = { contact->GetFixtureA(), contact->GetFixtureB() };
    std::vector<CollisionData>::iterator pos;
    pos = std::find(collisions.begin(), collisions.end(), myCollision);
    if (pos != collisions.end()) {
        collisions.erase(pos);
    }
}

void CollisionDetector::PreSolve(b2Contact* contact,
                                 const b2Manifold* oldManifold) {
}

void CollisionDetector::PostSolve(b2Contact* contact,
                                  const b2ContactImpulse* impulse) {
}