
extern "C" int mul_real(int a, int b)
{
    float x = *(float*)&a;
    float y = *(float*)&b;
    float res = x * y;
    return *(int*)&res;
}
