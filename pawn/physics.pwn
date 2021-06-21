/*
    posX - circle position on X axis (fixed point)
    posY - circle position on Y axis (fixed point)
    simplePosX - circle position on X axis
    simplePosY - circle position on Y axis
    spdX - circle X speed
    spdY - circle Y speed
    mass - circle mass (fixed point)
    radius - circle radius
    CoR - Coefficient of restitution (fixed point)
    cube - module owner of this circle
    face - face owner of this circle
    cubeT - cube transfer, last module owner. Can be used for resending messages
    faceT - face transfer, last face owner. Can be used for resending messages
*/
#define PHYSICS_CIRCLE_DATA .posX, .posY, .simplePosX, .simplePosY, .spdX, .spdY, .mass, .radius, .CoR, .cube, .face, .cubeT, .faceT, 

#include "math.pwn"

Physics_Overlap(overlap, positionDifference, distance) {
    return overlap * positionDifference / distance
}

Physics_Circle_Vs_Circle_obj(circle1[PHYSICS_CIRCLE_DATA], circle2[PHYSICS_CIRCLE_DATA]) {
    new r = (circle1.radius + circle2.radius) * (circle1.radius + circle2.radius);
    return r > CheapDistance(circle1.simplePosX - circle2.simplePosX, circle1.simplePosY - circle2.simplePosY);
}

Physics_Circle_vs_AABB_obj(circle[PHYSICS_CIRCLE_DATA], rectX, rectY, rectWidth, rectHeight, fakeCircle[PHYSICS_CIRCLE_DATA] = 0, isTrigger = 0) {
    new x = Max(rectX, Min(circle.simplePosX, rectX + rectWidth));
    new y = Max(rectY, Min(circle.simplePosY, rectY + rectHeight));

    new distance = CheapDistance(x - circle.simplePosX, y - circle.simplePosY);
    if (distance < (circle.radius * circle.radius)) {
        fakeCircle.simplePosX = x;
        fakeCircle.simplePosY = y;
        fakeCircle.spdX = -circle.spdX;
        fakeCircle.spdY = -circle.spdY;
        fakeCircle.mass = (circle.mass * 230) >> 8;
        fakeCircle.radius = 1;
        fakeCircle.CoR = 256;

        if (!isTrigger) {
            distance = sqrt(distance);
            new overlap = (distance - circle.radius - fakeCircle.radius);
            circle.simplePosX -= Physics_Overlap(overlap, (circle.simplePosX - fakeCircle.simplePosX), distance);
            circle.simplePosY -= Physics_Overlap(overlap, (circle.simplePosY - fakeCircle.simplePosY), distance);
        }
        
        return 1;
    }
    return 0;
}

Physics_Circle_Vs_LineSegment(circle[PHYSICS_CIRCLE_DATA], lineSX, lineSY, lineEX, lineEY, fakeCircle[PHYSICS_CIRCLE_DATA] = 0) {
    new lineX1 = lineEX - lineSX;
    new lineY1 = lineEY - lineSY;

    new lineX2 = circle.simplePosX - lineSX;
    new lineY2 = circle.simplePosY - lineSY;

    new boundaryLength = lineX1 * lineX1 + lineY1 * lineY1;

    // Sort of coeficient that shows how deep our circle penetrate line segment, values from 0 - 1 (in fixed point representation)
    new t = (Max(0, Min(boundaryLength, (lineX1 * lineX2 + lineY1 * lineY2))) << 8) / boundaryLength;

    new closestPointX = lineSX + (t * lineX1 >> 8);
    new closestPointY = lineSY + (t * lineY1 >> 8);

    new distance = Distance(circle.simplePosX - closestPointX, circle.simplePosY - closestPointY);

    // 1 is thickness of line segment
    if (distance <= (circle.radius + 1)) {
        
        // We treat collision point as a unmoveble circle
        fakeCircle.simplePosX = closestPointX;
        fakeCircle.simplePosY = closestPointY;
        // Need to make a bounce
        fakeCircle.spdX = -circle.spdX;
        fakeCircle.spdY = -circle.spdY;
        fakeCircle.mass = (circle.mass * 230) >> 8;
        fakeCircle.radius = 1;
        fakeCircle.CoR = 256;
        
        // Try to prevent circle from sinking in line segment
        new overlap = (distance - circle.radius - fakeCircle.radius);
        circle.simplePosX -= Physics_Overlap(overlap, (circle.simplePosX - fakeCircle.simplePosX), distance);
        circle.simplePosY -= Physics_Overlap(overlap, (circle.simplePosY - fakeCircle.simplePosY), distance);

        // Find if we moving toward the segment
        new dotProd = 0;
        if ((lineX1 * lineY2 - lineX2 * lineY1) > 0) {
            // Left
            dotProd = Vector2D_Dot_Product(-lineY1, lineX1, circle.spdX, circle.spdY);
        } else {
            // Right
            dotProd = Vector2D_Dot_Product(lineY1, -lineX1, circle.spdX, circle.spdY);
        }

        // If not it's unnecessary do further calculations
        return (dotProd < 0);
    }
    return 0;
}

// Resolve collision without mass
Physics_Res_CvC_Coll_Massless(circle1[PHYSICS_CIRCLE_DATA], circle2[PHYSICS_CIRCLE_DATA]) {
    new diffX = circle1.simplePosX - circle2.simplePosX;
    new diffY = circle1.simplePosY - circle2.simplePosY;

    new magnitude = Distance(diffX, diffY);
    
    // Overlap
    new overlap = (magnitude - circle1.radius - circle2.radius) >> 1;
    circle1.posX = (circle1.simplePosX -= Physics_Overlap(overlap, circle1.simplePosX - circle2.simplePosX, magnitude)) << 8;
    circle1.posY = (circle1.simplePosY -= Physics_Overlap(overlap, circle1.simplePosY - circle2.simplePosY, magnitude)) << 8;

    circle2.posX = (circle2.simplePosX += Physics_Overlap(overlap, circle1.simplePosX - circle2.simplePosX, magnitude)) << 8;
    circle2.posY = (circle2.simplePosY += Physics_Overlap(overlap, circle1.simplePosY - circle2.simplePosY, magnitude)) << 8;

    // Normal
    new normalX = (diffX << 8) / magnitude;
    new normalY = (diffY << 8) / magnitude;

    new relativeVelocityX = circle1.spdX - circle2.spdX;
    new relativeVelocityY = circle1.spdY - circle2.spdY;

    new speed = relativeVelocityX * normalX + relativeVelocityY * normalY;

    circle1.spdX -= (speed * normalX) >> 16;
    circle1.spdY -= (speed * normalY) >> 16;

    circle2.spdX += (speed * normalX) >> 16;
    circle2.spdY += (speed * normalY) >> 16;
}

// Resolve collision with mass
Physics_Res_CvC_Coll_Mass(circle1[PHYSICS_CIRCLE_DATA], circle2[PHYSICS_CIRCLE_DATA]) {
    new diffX = circle1.simplePosX - circle2.simplePosX;
    new diffY = circle1.simplePosY - circle2.simplePosY;

    new magnitude = Distance(diffX, diffY);
    
    // Overlap
    new overlap = (magnitude - circle1.radius - circle2.radius) >> 1;
    circle1.posX = (circle1.simplePosX -= Physics_Overlap(overlap, circle1.simplePosX - circle2.simplePosX, magnitude)) << 8;
    circle1.posY = (circle1.simplePosY -= Physics_Overlap(overlap, circle1.simplePosY - circle2.simplePosY, magnitude)) << 8;

    circle2.posX = (circle2.simplePosX += Physics_Overlap(overlap, circle1.simplePosX - circle2.simplePosX, magnitude)) << 8;
    circle2.posY = (circle2.simplePosY += Physics_Overlap(overlap, circle1.simplePosY - circle2.simplePosY, magnitude)) << 8;

    // Normal
    new normalX = (diffX << 8) / magnitude;
    new normalY = (diffY << 8) / magnitude;

    new relativeVelocityX = circle1.spdX - circle2.spdX;
    new relativeVelocityY = circle1.spdY - circle2.spdY;

    new speed = relativeVelocityX * normalX + relativeVelocityY * normalY;

    speed = (speed * Min(circle1.CoR, circle2.CoR)) >> 8;

    new impulse = ((speed << 1) << 8) / (circle1.mass + circle2.mass)

    circle1.spdX -= ((impulse * circle2.mass >> 16) * normalX) >> 8;
    circle1.spdY -= ((impulse * circle2.mass >> 16) * normalY) >> 8;

    circle2.spdX += ((impulse * circle1.mass >> 16) * normalX) >> 8;
    circle2.spdY += ((impulse * circle1.mass >> 16) * normalY) >> 8;
}


Physics_DeserializeCircle(serializedData_1, serializedData_2, circle[PHYSICS_CIRCLE_DATA]) {
    new negativeFlags = serializedData_2 & 0xF;
    circle.posY = (circle.simplePosY = ( serializedData_1        & 0xFF) * ((negativeFlags & 1) ? (-1) : (1))) << 8;
    circle.posX = (circle.simplePosX = ((serializedData_1 >>  8) & 0xFF) * ((negativeFlags & 2) ? (-1) : (1))) << 8;
    circle.spdY = ((serializedData_1 >> 16) & 0xFF) * ((negativeFlags & 4) ? (-1) : (1));
    circle.spdX = ((serializedData_1 >> 24) & 0xFF) * ((negativeFlags & 8) ? (-1) : (1));
    circle.mass = ((serializedData_2 >> 4) & 0xF) << 8;
    circle.radius = ((serializedData_2 >> 8) & 0x3F);
    circle.face = ((serializedData_2 >> 14) & 0x3);
    circle.cube = ((serializedData_2 >> 16) & 0x7);
    circle.faceT = ((serializedData_2 >> 19) & 0x3);
    circle.cubeT = ((serializedData_2 >> 21) & 0x7);
}

Physics_SerializeCircle(obj[PHYSICS_CIRCLE_DATA], &serializedData_1, &serializedData_2) {
    new posX = obj.simplePosX;
    new posY = obj.simplePosY;
    new spdX = obj.spdX;
    new spdY = obj.spdY;
    new negativeFlags = 0;
    if (posY < 0) {
        posY = -posY;
        negativeFlags |= 1;
    }
    if (posX < 0) {
        posX = -posX;
        negativeFlags |= 2;
    }
    if (spdY < 0) {
        spdY = -spdY;
        negativeFlags |= 4;
    }
    if (spdX < 0) {
        spdX = -spdX;
        negativeFlags |= 8;
    }
    serializedData_1 = (spdX << 24) | (spdY << 16) | (posX << 8) | posY;
    serializedData_2 = (obj.cubeT << 21) | (obj.faceT << 19) | (obj.cube << 16) | (obj.face << 14) | (obj.radius << 8) | ((obj.mass >> 8) << 4) | negativeFlags
}