
def pb(x, b):
    s = ''
    for _ in range(b):
        s += str(x % 2)
        x //= 2
    return s[::-1]

with open('test.code', 'r') as fin:
    with open('test.data', 'w') as f:
        for l in fin:
            a = l.split(' ')
            for i in range(1, len(a)):
                a[i] = a[i][0:-1]
            print(a)
            o = ''
            if a[0] == "ADDI":
                o += pb(int(a[3]), 12)
                o += pb(int(a[2][1:]), 5)
                o += pb(0b000, 3)
                o += pb(int(a[1][1:]), 5)
                o += pb(0b0010011, 7)
            elif a[0] == "SLTI":
                o += pb(int(a[3]), 12)
                o += pb(int(a[2][1:]), 5)
                o += pb(0b010, 3)
                o += pb(int(a[1][1:]), 5)
                o += pb(0b0010011, 7)
            elif a[0] == "SLTIU":
                o += pb(int(a[3]), 12)
                o += pb(int(a[2][1:]), 5)
                o += pb(0b011, 3)
                o += pb(int(a[1][1:]), 5)
                o += pb(0b0010011, 7)
            elif a[0] == "XORI":
                o += pb(int(a[3]), 12)
                o += pb(int(a[2][1:]), 5)
                o += pb(0b100, 3)
                o += pb(int(a[1][1:]), 5)
                o += pb(0b0010011, 7)
            elif a[0] == "ORI":
                o += pb(int(a[3]), 12)
                o += pb(int(a[2][1:]), 5)
                o += pb(0b110, 3)
                o += pb(int(a[1][1:]), 5)
                o += pb(0b0010011, 7)
            elif a[0] == "ANDI":
                o += pb(int(a[3]), 12)
                o += pb(int(a[2][1:]), 5)
                o += pb(0b111, 3)
                o += pb(int(a[1][1:]), 5)
                o += pb(0b0010011, 7)
            elif a[0] == "SLLI":
                o += pb(int(a[3]), 12)
                o += pb(int(a[2][1:]), 5)
                o += pb(0b111, 3)
                o += pb(int(a[1][1:]), 5)
                o += pb(0b0010011, 7)
            print(len(o), o)
            for i in range(4):
                print(o[i*8:i*8+8], file=f)
