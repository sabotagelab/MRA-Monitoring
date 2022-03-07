function out=recursive_monitor(signal, formula, ad, rot)
%signal will be either the approximation or details from a wavelet
%decompostion.
%Formula will be the output from MRA_DT_STL.
%ad = "a" for approximation signal or "d" for detail. This tells the
%formula which signal is being monitored and thus which extend proposition
%to use.
%rot is total rotation up to this point. Should be 0 at the beginning of
%monitoring. Becomes altered as we walck down the structure of the formula.

%The signal must be the same length as the every extended proposition in
%the formula.

if strcmp(formula{1}, 'G') 
    %Create a list of booleans for each position the formula is concerned
    %with
    sat=zeros(1,formula{2}(2)-formula{2}(1)+1);
    
    pos=1;
    %Check the following formula recursively for each position
    for i=formula{2}(1):formula{2}(2)
        sat(pos)=recursive_monitor(circshift(signal,-i),formula{3},ad, rot+i);
        pos=pos+1;

    end %i
    
    %return true if all are true
    out=all(sat);
    
    
elseif strcmp(formula{1}, 'F') 
    %Create a list of bools
    sat=zeros(1,formula{2}(2)-formula{2}(1)+1);
    
    %check each position/rotation
    pos=1;
    for i=formula{2}(1):formula{2}(2)
        
        sat(pos)=recursive_monitor(circshift(signal,-i),formula{3},ad, rot+i);
        pos=pos+1;
    end %i
    %return true if any are true
    out=any(sat);
    
    
elseif strcmp(formula{1}, 'OR')
    sat=[0,0];
    
    %Call recursive_monitor on both the formulas that or operates on. 
    sat(1)=recursive_monitor(signal,formula{2},ad,rot);
    sat(2)=recursive_monitor(signal,formula{3},ad,rot);
    
    %if any return true set out to true
    out=any(sat);

elseif strcmp(formula{1}, 'AND')
    sat=[0,0];
    
    %Call recursive_monitor on both the formulas that AND operates on. 
    sat(1)=recursive_monitor(signal,formula{2},ad,rot);
    sat(2)=recursive_monitor(signal,formula{3},ad,rot);
    
    %if all return true set out to true
    out=all(sat);
     
elseif strcmp(formula{1},'U')
    %Iterate through each each time step and confirm that the
    %first formula is true at least until the second formula is.
    sat=0;
    for i=formula{2}(1):formula{2}(2) %Each time that the forumal cares about
        
        %Call recursive_monitor on each formula until acts on, over the
        %interval of until. 
        phi1=recursive_monitor(circshift(signal,-i),formula{3},ad,rot+i);
        phi2=recursive_monitor(circshift(signal,-i),formula{4},ad,rot+1);
        
        if phi2 %If we see any phi2==TRUE set sat=1 and end the loop
            sat=1;
            break
        elseif ~phi1 && ~phi2 %if we ever see no formula return true, end the 
                                %loop and set sat = 0. If there is
                                %satisfaction before this point, the loop
                                %should have ended.
                                
            sat=0;
            break
        end %if
            
    end %i
    out=sat;
    
elseif strcmp(formula{1}, 'R')
    %
    sat=0;
    
    %initialize a boolean list for each phi1 and phi2 that will hold sat
    %signals
    phi1=ones(1,formula{2}(2)-formula{2}(1)+1);
    phi2=ones(1,formula{2}(2)-formula{2}(1)+1);
    
    %Fill in list for each formula over the interval. This will then fill
    %in which time steps phi1 and phi2 are satisfied at
    phi_pos=1;
    for i=formula{2}(1):formula{2}(2)
        phi1(phi_pos)=recursive_monitor(circshift(signal,-i),formula{3},ad,rot+i);
        phi2(phi_pos)=recursive_monitor(circshift(signal,-i),formula{3},ad,rot+i);
        phi_pos=phi_pos+1;
    end %i
    
    %If phi2 returns true for every time in pos, we have satisfaction.
    if all(phi2)
        sat=1;
    end %if
    
    L=length(phi1);
    for i=1:L
        
        %don't finish the loop if we find satisfaction above or in a
        %previous iteration of the loop. 
        if sat==1
            break
        end %if
        
        for j=1:i-1
            if ~phi2(i) && phi1(j) %if not current phi2(i) and some previous phi1==1, 
                                    %we have satisfaction, unlike the
                                    %stones. 
                sat=1;
                break
            end %if
        end %j
        
    end %i
    
    out=sat;

elseif isa(formula{2}{3},'double') %Formula is p or ~p. Both p and ~p have 
                                   %the same structure coming out of 
                                   %MRA-DT-STL
    
    %Set the index of formula we care about. MRA_DT_STL returns both detail
    %extended proposition and approximation extended proposition. If ad='d'
    %that denotes that recursive_monitor should check against the detail
    %proposition
    if strcmp(ad,'d')
        ind=2;
    else 
        ind=1;
    end%if
    
    %Check each timestep of the signal against the corresponding timestep
    %of the extended proposition
    out=all(signal>formula{ind}{3}(:,1)) && all(signal<formula{ind}{3}(:,2));
        
end%if
    
    
end%function