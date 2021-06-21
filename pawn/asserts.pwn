
const DEBUG_ASSERTS_CUBE_ALL = 9;

#define DUBUG_ASSERTS_SKIP

#ifndef DUBUG_ASSERTS_SKIP

_assert_EQUAL(x, y, message = 0) {
    new res = x == y;
    #ifdef DEBUG_ASSERT_PRINT
    if (!res)
        printf("Not equal: %d %d! Message: %s\n", x,y,message)
    #endif
    return res;
}

_assert_NOT_EQUAL(x, y, message = 0) {
    new res = x != y;
    #ifdef DEBUG_ASSERT_PRINT
    if (!res)
        printf("Equal: %d %d! Message: %s\n", x,y,message)
    #endif
    return res;
}

_assetr_BETWEEN(x,yStart,yEnd, message = 0) {
    new res = (x >= yStart) && (x <= yEnd);
    #ifdef DEBUG_ASSERT_PRINT
    if (!res)
        printf("Not between: %d, [%d %d]! Message: %s\n", x, yStart, yEnd ,message)
    #endif
    return res;
}

_assetr_NOT_BETWEEN(x,yStart,yEnd, message = 0) {
    new res = (x < yStart) || (x > yEnd);
    #ifdef DEBUG_ASSERT_PRINT
    if (!res)
        printf("Between: %d, [%d %d]! Message: %s\n", x, yStart, yEnd ,message)
    #endif
    return res;
}

_printf_cube_N_number(number,additionalMessage[],cubeN = DEBUG_ASSERTS_CUBE_ALL) {
    if (cubeN == DEBUG_ASSERTS_CUBE_ALL)
        cubeN = abi_cubeN;
    if (cubeN == DEBUG_ASSERTS_CUBE_ALL || cubeN == abi_cubeN) {
        printf("Cube N:%d report value with msg %s: %d\n",cubeN,additionalMessage,number);
    }
}

_printf_cube_N_string(string[],cubeN = DEBUG_ASSERTS_CUBE_ALL) {
    if (cubeN == DEBUG_ASSERTS_CUBE_ALL)
        cubeN = abi_cubeN;
    if (cubeN == DEBUG_ASSERTS_CUBE_ALL || cubeN == abi_cubeN)
        printf("Cube N:%d report string: %s\n",cubeN,string);
}
#else
_printf_cube_N_number(number,additionalMessage[],cubeN = DEBUG_ASSERTS_CUBE_ALL)
{

}

_printf_cube_N_string(string[],cubeN = DEBUG_ASSERTS_CUBE_ALL)
{

}
#endif

