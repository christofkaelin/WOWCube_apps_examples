new _a = 1103515245;
new _c = 12345;
new _m = 2147483647;
new _seed = 0; // = (abi_MTD_GetFaceAccelX(0) + abi_MTD_GetFaceAccelY(0) + abi_MTD_GetFaceAccelZ(0))%0xFFFFFFFF;

// Fixed point accuracy
const FP = 8;
const PI_FIXED = 804;
const PI_2_FIXED = PI_FIXED >> 1;
const PI_4_FIXED = PI_FIXED >> 2;
const RAD_2_DEG = (180 << FP) / PI_FIXED;

new sin8LUT[] = [
    0, 4, 8,
    13, 17, 22,
    26, 31, 35,
    40, 44, 48,
    53, 57, 61,
    66, 70, 74,
    79, 83, 87,
    91, 95, 100,
    104, 108, 112,
    116, 120, 124,
    128, 131, 135,
    139, 143, 146,
    150, 154, 157,
    161, 164, 167,
    171, 174, 177,
    181, 184, 187,
    190, 193, 196,
    198, 201, 204,
    207, 209, 212,
    214, 217, 219,
    221, 223, 226,
    228, 230, 232,
    233, 235, 237,
    238, 240, 242,
    243, 244, 246,
    247, 248, 249,
    250, 251, 252,
    252, 253, 254,
    254, 255, 255,
    255, 255, 255,
    256
];

Random(min, max) {
    _seed = (_a * _seed + _c) % _m
    return (min + (_seed % (max - min)));
}

Round( & number, const base) {
    if (number * 10 / base % 10 > 5) {
        number /= base;
        number += GetSign(number);
    } else
        number /= base;
}
GetSign(number) {
    return number < 0 ? -1 : 1;
}
stock pow(a, n) {
    if (!n)
        return 1;

    new
    b = a;

    while (--n != 0) {
        b *= a;
    }

    return b;
}
ABS(value) {
    return value < 0 ? -value : value;
}
// Square root of integer
int_sqrt(s) {
    new x0 = s >> 1; // Initial estimate
    new x1;

    // Sanity check
    if (x0) {
        x1 = (x0 + s / x0) >> 1; // Update

        while (x1 < x0) // This also checks for cycle
        {
            x0 = x1;
            x1 = (x0 + s / x0) >> 1;
        }

        return x0;
    } else {
        return s;
    }
}

FixedSin (angle) {
    angle %= 360;
    if (angle <= 90) {
        return sin8LUT[angle];
    } else if (angle <= 180) {
        return sin8LUT[180 - angle];
    } else if (angle <= 270) {
        return -sin8LUT[angle - 180];
    } else {
        return -sin8LUT[360 - angle];
    }
}

FixedCos (angle) {
    angle %= 360;
    if (angle <= 90) {
        return sin8LUT[90 - angle];
    } else if (angle <= 180) {
        return -sin8LUT[angle - 90];
    } else if (angle <= 270) {
        return -sin8LUT[270 - angle];
    } else {
        return sin8LUT[angle - 270];
    }
}

// "Efficient approximations for the arctangent function", S. Rajan, Sichun Wang, R. Inkol, A. Joyal
Atan(x) {
    return ((PI_4_FIXED * x >> FP) - ((x * (ABS(x) - 256) >> FP) * (62 + (17 * ABS(x) >> FP)) >> FP)) * RAD_2_DEG >> FP;
}

RotatePoint(&pointToRotX, &pointToRotY, angle) {
    angle -= newAngles[activeFace];
    new sin = FixedSin(angle);
    new cos = FixedCos(angle);
    pointToRotX = (((pointToRotX - entityPosX) * cos >> 8) - ((pointToRotY - entityPosY) * sin >> 8) + (entityPosX));
    pointToRotY = (((pointToRotX - entityPosX) * sin >> 8) + ((pointToRotY - entityPosY) * cos >> 8) + (entityPosY));
}
// More accurate but more expensive sqrt
sqrt(x) {
    new s, t;
    s = 1;  t = x;
    // Decide the value of the first tentative
    while (s < t) {
        s <<= 1;
        t >>= 1;
    }
    do {
        t = s;
        // x1=(N / x0 + x0)/2 : recurrence formula
        s = (x / s + s) >> 1;
    } while (s < t);
    return t;
}

Min(x, y) {
    return (x > y) ? (y) : (x);
}

Max(x, y) {
    return (x > y) ? (x) : (y);
}

Vector2D_Dot_Product(v1_x, v1_y, v2_x, v2_y) {
    return (v1_x * v2_x + v1_y * v2_y);
}

Distance(x, y) {
    return sqrt(x * x + y * y);
}

CheapDistance(x, y) {
    return (x * x + y * y);
}