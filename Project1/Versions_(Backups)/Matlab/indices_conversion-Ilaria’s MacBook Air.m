function [R] = indices_conversion(I,rem)
REM  = (I==4);        %Beta  = REM
NR1  = (I==3);        %Alpha = STAGE 1
NR2  = (I==2);        %Theta = STAGE 2
NR34 = (I==1);        %Delta = STAGE 3 & 4

if rem
     R(REM==1)=0.9;
else R(REM==1)=1;
end
R(NR1==1) =1;
R(NR2==1) =2;
R(NR34==1)=3;