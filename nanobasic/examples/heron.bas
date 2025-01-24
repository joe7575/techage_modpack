let v = 400000 ' Value to calculate the square root
let s = 1000   ' Initial guess

REM Root calculation according to Heron
for i = 1 to 10
    let t = ((v / s) + s) / 2
    if t = s goto exit
    let s = t
next i

exit:
print i, s
end
