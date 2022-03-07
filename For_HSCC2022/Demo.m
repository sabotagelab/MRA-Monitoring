%% This is a demo file using MRA_DT_STL. 
%It is recommended that only one section is run at a time, to reduce output
clear all
%% First create formula. 

%A couple of propositions. Feel free to make your own. 
p={'p','>',0.5};
q={'q','<',-0.5};

%Some example formulas

%p until q
formula1=p;

%Eventually q
formula2={'F',[0,7],p};

%Globaly Eventually q
formula3={'G',[0,5],q};

%q until p
formula4={'U',[0,7],q,p};

%formula1 and formula2
formula5={'AND',formula2,formula3};


%% Create wavelet basis

%Choose signal length. Only 16 works as this file is written.
N=16;

%Choose wavelet. Some examples are included
wvlt='haar';
%wvlt='db2';
% wvlt='sym4';

%Make our basis to feed into algorithm
V=create_basis(wvlt,N,1,'V');
W=create_basis(wvlt,N,1,'W');

%% Function 1

%Get the low resolution formula l
low_res_formula1=MRA_DT_STL(formula1, V, W,[-1,1]);


disp(' ')
disp(' ')
%Print out the formula
disp('Formula1 output')
disp([low_res_formula1{1},low_res_formula1{2}])

%Quick plots to visualize the extended propositions. 
figure
plot(low_res_formula1{1}{3},'.-')
title("p_{-1} for approx from formula1")

figure
plot(low_res_formula1{2}{3},'.-')
title("p_{-1} for details from formula1")

%% Function 2

low_res_formula2=MRA_DT_STL(formula2, V, W,[-1,1]);


disp(' ')
disp(' ')
%Print out the formula.
disp('Formula2 output')
disp({low_res_formula2{1},low_res_formula2{2}})
disp([low_res_formula2{3}{1},low_res_formula2{3}{2}])

figure
plot(low_res_formula2{3}{1}{3},'.-')
title("p_{-1} for approx from formula2")

figure
plot(low_res_formula2{3}{2}{3},'.-')
title("p_{-1} for details from formula2")

%% Function 3

low_res_formula3=MRA_DT_STL(formula3, V, W,[-1,1]);


disp(' ')
disp(' ')
%Print out the formula.
disp('Formula3 output')
disp({low_res_formula3{1},low_res_formula3{2}})
disp([low_res_formula3{3}{1},low_res_formula3{3}{2}])

figure
plot(low_res_formula3{3}{1}{3},'.-')
title("q_{-1} for approx from formula3")

figure
plot(low_res_formula3{3}{2}{3},'.-')
title("q_{-1} for details from formula3")

%% Function 4

low_res_formula4=MRA_DT_STL(formula4, V, W,[-1,1]);


disp(' ')
disp(' ')
%Print out the formula.
disp('Formula4 output')
disp([low_res_formula4{3}{1},low_res_formula4{3}{2}])
disp({low_res_formula4{1:2}})
disp([low_res_formula4{4}{1},low_res_formula4{4}{1}])

%% Function 5

low_res_formula5=MRA_DT_STL(formula5, V, W,[-1,1]);


disp(' ')
disp(' ')
%Print out the formula.
disp('Formula 5 output here')
disp(low_res_formula5{2})
disp(low_res_formula5{1})
disp(low_res_formula5{3})


%Plot both high and low resolution extended propositions for both p and q. 
figure
plot(low_res_formula5{2}{3}{1}{3},'.-')
title("p_{-1} for approx from formula5")

figure
plot(low_res_formula5{2}{3}{2}{3},'.-')
title("p_{-1} for details from formula5")


figure
plot(low_res_formula5{3}{3}{1}{3},'.-')
title("q_{-1} for approx from formula5")

figure
plot(low_res_formula5{3}{3}{2}{3},'.-')
title("q_{-1} for details from formula5")


%% Make a signal with length 16. 

a=0.9; b=-0.9; 
x=[b,b,b,b,b,b,a,a,a,b,a,b,a,a,b,b]';

%Project that signal onto V and W
proj=V*V'*x;
details=W*W'*x;



%% Run recursive monitor on deconstructed formula1
disp(' ')
disp(' ')
proj1sat=recursive_monitor(proj, low_res_formula1, 'a',0)

det1sat=recursive_monitor(details, low_res_formula1, 'd',0)

%% Run recursive monitor on deconstructed formula2
disp(' ')
disp(' ')
proj2sat=recursive_monitor(proj, low_res_formula2, 'a',0)

det2sat=recursive_monitor(details, low_res_formula2, 'd',0)

%% Run recursive monitor on deconstructed formula3
disp(' ')
disp(' ')
proj3sat=recursive_monitor(proj, low_res_formula3, 'a',0)

det3sat=recursive_monitor(details, low_res_formula3, 'd',0)

%% Run recursive monitor on deconstructed formula4
disp(' ')
disp(' ')
proj4sat=recursive_monitor(proj, low_res_formula4, 'a',0)

det4sat=recursive_monitor(details, low_res_formula4, 'd',0)

%% Run recursive monitor on deconstructed formula5
disp(' ')
disp(' ')
proj5sat=recursive_monitor(proj, low_res_formula5, 'a',0)

det5sat=recursive_monitor(details, low_res_formula5, 'd',0)



%% Implementation of wavelet_monitor

J=3; %J must not be such that N<2^J
x=rand(N,1);
wvlt_basis{J+1}=[]; %init for increased speed.

%create all W basis.
for i=1:J
    wvlt_basis{i}=create_basis(wvlt,N,i,'W');
end% i

%Create V's
wvlt_basis{J+1}=create_basis(wvlt,N,J,'V');

for i=1:J+1
    signal{i}=wvlt_basis{i}*wvlt_basis{i}'*x;
end %i


wave_mon_sat=wavelet_monitor(signal, formula5, wvlt_basis, [-1,1])
