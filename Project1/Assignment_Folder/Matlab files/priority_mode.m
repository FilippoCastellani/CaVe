function [R] = priority_mode(x,perc_thr)
T=tabulate(x);
G=sortrows(T,3);
%G=T;
if(G(1,3)>perc_thr)
    %disp("true 1")
    R=G(1,1);
elseif(G(2,3)>perc_thr)
    %disp("true 2")
    R=G(2,1);
elseif(G(3,3)>perc_thr)
    %disp("true 3")
    R=G(3,1);
else
    %disp("true 4")
    R=mode(x);
end

end

