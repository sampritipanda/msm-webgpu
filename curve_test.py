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

a = 0x24c7d5b939454dc2e5621c8d1ebe60f5a8dde102249b2bb71564dc7c1a8f63c
b = 0x12ebb42bc8f4fbf5832d3d432e9aaa6641ec44986ab9c88febdfe7f5a5c7fd
c = 0x2e4abc7c0926d59d270d036fb9312316ce58c46861263dff415e89c9152c3121

kek = from_jacob((a, b, c))
for i in range(1024+1):
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
