function [R] = sliding_assignment(x,m,thr)
if (mod(m,2))
    m=m+1;
lor=floor(m/2);
for i=1:1:length(x)
    if (i<lor)
        R(i)=x(i)
    elseif (i>=length(x)-lor)
        R(i)=x(i)
    else
        R(i)=priority_mode(x(i:i+m-1),thr)