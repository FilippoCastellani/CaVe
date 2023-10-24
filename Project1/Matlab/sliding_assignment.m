function [R] = sliding_assignment(x,m,thr)
if(mod(m,2)==0)
    m=m+1;
end

lor=floor(m/2);

for i=1:1:length(x)
    if (i<=lor)
        %disp("if 1----------------------")
        R(i)=x(i);
    elseif (i>=length(x)-m)
        %disp("if 2----------------------")
        R(i)=x(i);
    else
        %disp("if 3----------------------")
        %disp(i);
        R(i)=priority_mode(x(i-lor:i+lor),thr);
    end
end
end