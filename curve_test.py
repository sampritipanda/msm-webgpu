from sage.all_cmdline import *

P = GF(0x40000000000000000000000000000000224698fc094cf91b992d30ed00000001)
E = EllipticCurve(P, [0, 5])

def from_jacob(res):
    res = (P(res[0]), P(res[1]), P(res[2]))
    return E(res[0]/(res[2]**2), res[1]/(res[2]**3))

G = E(22304380549750642616165107876029345325911088198117424279971154895103981677948, 14354096399413720219912473247241970521073754194408414292017996939864946211566)
s = 115792089237316195423570985008687907853269984665640564039457584007913129639935
print(G)
print(s)

a = 0x3d50eb7491f36a1c746cf044d8e97fd1e5f6d0d6e4da9633d37275b198640140
b = 0xbe564a8781cbd8fa78a8ea366e6d0a03b368ad2033cd06efa3954c0e5b05603
c = 0x31e71da1d2922ce27f46dade9cd8d540ed3046ae8c4eb87c10427d10ca722637

kek = from_jacob((a, b, c))
for i in range(4096+1):
    if kek == G * s * 64 * i:
        print(i)
        break

exit()

while True:
    a = eval(input().split()[-1])
    b = eval(input().split()[-1])
    c = eval(input().split()[-1])
   
    try:
        print(from_jacob((a, b, c)))
    except Exception as e:
        print(e)
