clrscr()
setcur(1,1)
start:
gosub prnt_line
print "|                         Test Report                      |"
gosub prnt_line

const MAX = 2147483647
_max = MAX
print "| The largest number is" _max "                       |"
print "| The almost largest number is" _max - 1 "                |"
dim AR(5)
for i = 1 to 5
  AR(i) = i + 1
next i

let B$ = string$(10,"A")
print "| Length of string 'B$' should be 10:" len(B$) "                 |"

i = 21
print "|  ";
while i > 0
    print i;
    i = i - 1
loop
print "  |"

for j = 1 to 5
  for l = 1 to 2
    if l = 1 then
      print "|";
      for m = 1 to 58
        print"=";
      next
      print "|"
    else
      if l = 2 then
        print "| ";
        for k = 1 to j
          print str$(j);":";k;
        next k
        print SPC(57 - j * 4);
        print "|"
      else
        print "|";
        for m = 1 to 58
          print"=";
        next
        print "|"
      endif
    endif
  next l
next j

print "| "; : free : print "              |"
for i = 1 to (512 / 4) - 1
  dim BR(i)
next
dim BR1(127)
dim BR2(127)
dim BR3(127)
dim BR4(127)
dim BR5(127)
dim BR6(127)
dim BR7(127)
dim BR8(127)
dim BR9(127)
dim BRA(127)
dim BRB(99) ' => 2000 bytes free
print "| "; : free : print "              |"
erase BR
erase BR1
erase BR2
erase BR3
erase BR4
erase BR5
erase BR6
erase BR7
erase BR8
erase BR9
erase BRA
erase BRB
print "| "; : free : print "              |"

C1 = 100
C2 = 101
if C1 < C2 then print "|  1";
if c1 = c2 then i = 0 else print "  2";
if c1 + 1 <= c2 then goto label1
print "c1 + 1 is not <= c2"
label2:
if c1 > c2 then goto c1_c2 else print "  3";
if c1 + 1 >= c2 then
  print "  4";
endif
  
if c1 + 1 > c2 then
  print "c1 + 1 is > c2"
else
  print "  4";
endif

if c1 <> c2 then
  print "  5";
else
  print "c1 is not <> c2"
endif

if c1 > 99 and c2 > 100 and c1 < 101 and c2 < 102 and c1 <> c2 then
  print "  6";
endif

if c1 < 99 or c2 < 100 or c1 > 101 or c2 > 102 or c1 = c2 then
  print "Oops, should not happen"
else
  print "  7";
endif

for i = 1 to 4
  on i goto test_i1,test_i2,test_i3,test_i4
  test_on:
next

restore
for i = 1 to 2
    read var, s$
    print "  ";var;s$;
next

const min = -2147483648
if -2147483647 > min then print "  16";
print "   |"

print "| Time since program start = "; time();:print "sec                         |"
name$ = input$("| Your name")
setcur(30,23)
print "-> Hello "; name$ ; SPC(21 - len(name$)); "|"
age = input("| What is your age?") : setcur(60,24) : print "|"
print "| Next year you will be" age+1;"years old                       |"

s$ = "111***222***333"
print "|      ", left$(s$, 3), mid$(s$, 7, 3), right$(s$, 3), str$(444), hex$(1365),
s1$ = ":" + left$(s$, 3) + ":      |"
print s1$
print "|   ", left$(s$, 3) + mid$(s$, 7, 3) + right$(s$, 3), str$(_max), hex$(_max), "   |"
print "|                   "; 
print instr(1, s$, "1") instr(2, s$, "1") instr(1, s$, "2") instr(9, s$, "2") instr(1, s$, "3") instr(25, s$, "3");
print "                    |" 

v = val("1234567890")
l = len("1234567890")
print "|          v = 1234567890:";v;" l = 10:";l;"           |"
print "| Wait a moment..." : setcur(60,30) : print "|"
sleep(4)
gosub prnt_line
end

label1:
goto label2

prnt_line:
print "+";
for i = 1 to 58
  print "-";
next i
print "+"
return

test_i1:
  print "  8";
  goto test_on
  
test_i2:
  print "  9";
  goto test_on
  
test_i3:
  print "  10";
  goto test_on
  
test_i4:
  print "  11";
  goto test_on
  
data 12," 13",14," 15"
