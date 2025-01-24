i = 10
dim Pld(3)
dim Arr(5)

set1(Pld, 0, 32)
set1(Pld, 1, 1)
set1(Pld, 2, 255)
set1(Pld, 3, 250)
set4(Pld, 4, 4294967295)
print "Pld", Pld(0), Pld(1), Pld(2)

send(1, 1014, ref(Pld))
Arr(0) = 0
Arr(1) = 1
Arr(2) = 2
Arr(3) = 3
Arr(4) = 4
Arr(5) = 5
copy(ref(Arr), 4, ref(Pld), 0, 8)

for i = 0 to 50
  print ".";
next
print
print "Arr", Arr(0), Arr(1), Arr(2), Arr(3), Arr(4), Arr(5)
end

start:
  id = param()
  port = param()
  print "start", port, id, get1(Pld, 0), get1(Pld, 1), get1(Pld, 2), get1(Pld, 3), get4(Pld, 4)
  reti
