function out=MRA_DT_STL(formula, V, W, state_space)
%This function is algorithm 1 from HSCC '22 Submission
%This only works for 1D signals
%Line numbers in comments below refer to the paper published

%Takes in the formula, the basis V and W, and the state space bounds of the
%signal. 

%Note that the signals in the published work begin at t=0. Matlab starts at
%

%The formula is expected to have the following format:

%if a proposition, expects {"proposition name", ">/<", val}
%if globally or eventually, expect {"Op",[a,b], formula1}. Op is either 'F'
%or 'G'
%if release or until, expects {"Op",[a,b], formula1, formula2}. Op is
%either 'R' or 'U'.
%if 'and' or 'or', expects {"Op",[0,0], formula1, formula2}. Op is 'and' or
%'or'
%if not case, expects {'~', proposition}
%where [a,b] is the interval, where formula1 and 2 are structured as a
%valid formula following these structures, and proposition is a valid
%proposition following the first format. There in no support for something
%like ~Gp as that that be rewritten as E(~p), as one example. ~ can only be
%applied to propositions here. 

%Basis V and W are expected to have size N x K where N is signal length and
%K is determined by the level of decomposition. For a level 1 decomp,
%K=N/2. N must be even here.

%State space bounds are structured as an interval [one,two]


[N,K]=size(V); 

%Globally and Eventually  {'Op', interval as [a,b], formula}
%Globally and Eventually are not included in the published work, but they
%have been added here
if strcmp(formula{1}, 'G') || strcmp(formula{1}, 'E')

    ext=MRA_DT_STL(formula{3}, V, W, state_space);     
    out={formula{1},formula{2},ext};

%Not proposition case, Line 25
elseif strcmp(formula{1}, '~') && IsAProposition(formula{2})
    %For example if formula={'~',{'p','>',0.5}}
    formu=formula{2};
    %starting line 5
    v=zeros(N); %just initialize the lists
    w=zeros(N);
    
    
    %Calculating v_m,n, Line 5
    for n=1:N
        for m=1:N
            v(n,m)=V(n,:)*V(m,:)';
            w(n,m)=W(n,:)*W(m,:)';
        end %n
    end %m
    

    %initialize S
    S=state_space;
    
    %Set S to the correct interval for the proposition
    %Line 7.
    if contains(formu{2},'>')
        S(2)=formu{3}; %upper bound
    else
        S(1)=formu{3}; %lower bound
    end%if


    %create our extended propositions
    s = create_base_extended_prop(N,S,state_space,v);
    q = create_base_extended_prop(N,S,state_space,w);
    
%% Simple over approximation for a signal in [-1,1] 
    
    s(:,1)=s(:,1)-2;
    s(:,2)=s(:,2)+2;

    q(:,1)=q(:,1)-2;
    q(:,2)=q(:,2)+2;

 
    %Create the formula to return
    approx_prop={append('~',formu{1},'_approx'),formu{2},s};
    details_prop={append('~',formu{1},'_details'),formu{2},q};
    
    %Line 23
    out={approx_prop, details_prop};
    

    
%Proposition structured {'name', '>,<', constant}
%Line 4
elseif ~strcmp(formula{1}, '~') && IsAProposition(formula) 
    %
    %starting line 5
    v=zeros(N); %just initialize the lists
    w=zeros(N);
    
    %Calculating v_m,n
    for n=1:N
        for m=1:N
            v(n,m)=V(n,:)*V(m,:)';
            w(n,m)=W(n,:)*W(m,:)';
        end %m
    end %n
    
    %Initialize S
    S=state_space;
    
    %Note that this is the reverse of the previous. 
    if contains(formula{2},'<')
        S(2)=formula{3};
    else
        S(1)=formula{3};
    end%if
    
    
    %Line 8 I don't think I need yet, maybe later
    s = create_base_extended_prop(N,S,state_space,v);
    q = create_base_extended_prop(N,S,state_space,w);
        
%% Simple over approximation for a signal in [-1,1] 
    
    s(:,1)=s(:,1)-2;
    s(:,2)=s(:,2)+2;

    q(:,1)=q(:,1)-2;
    q(:,2)=q(:,2)+2;


%% 
    approx_prop={append(formula{1},'_approx'),formula{2},s};
    details_prop={append(formula{1},'_details'),formula{2},q};

    out={approx_prop, details_prop};
    
    
% formula1 operator formula1 {'Op', Interval as [a,b], formula1, formula2}
%Lines 27-30
elseif strcmp(formula{1}, 'AND') || strcmp(formula{1}, 'OR')
    ext1=MRA_DT_STL(formula{2}, V, W, state_space);%returns (approx_prop, details_prop) 
    ext2=MRA_DT_STL(formula{3}, V, W, state_space);
    out={formula{1},ext1,ext2};
else
    ext1=MRA_DT_STL(formula{3}, V, W, state_space);%returns (approx_prop, details_prop) 
    ext2=MRA_DT_STL(formula{4}, V, W, state_space);
    out={formula{1},formula{2},ext1,ext2};
end%if
    
    
    function out=IsAProposition(formula)
        if isa(formula{3},'double')
            out=1;
        else
            out=0;
        end%if
    end%IsAProposition











end%function