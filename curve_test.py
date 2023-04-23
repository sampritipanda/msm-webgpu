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

a = 0x3ac2ddb24d8d69be9dbe32da2406eecd42aba0ab663a451a8f1c0dfd0fbbf33f
b = 0x2089cd96378ef4673b01c17fa1586824c5b0e753ff261b9ec351a93c54982de0
c = 0x7b24c8c9d9f8c02814c7849ec7a92acee76411d4ccd2bae205f7c4b226e3fda

kek = from_jacob((a, b, c))
for i in range(256):
    if kek == G * s * 128 * i:
        print(i)

exit()

while True:
    a = eval(input().split()[-1])
    b = eval(input().split()[-1])
    c = eval(input().split()[-1])
   
    try:
        print(from_jacob((a, b, c)))
    except Exception as e:
        print(e)
