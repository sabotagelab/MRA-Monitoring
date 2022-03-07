function s=create_base_extended_prop(N,S,state_space,v)

    %This function creates the extendended proposition given the following:
    %Signal Length N
    %S is the constraint due to the proposition
    %state_space is the assumed state space of the signal [a,b]
    %v is v_{m,n} as constructed in MRA_DT_STL, is an NxN matrix


    %initialize our extended proposition
    s = zeros(N,2);
       

    for m=1:N %Line 9
        %lines 11-17.
        s(m,:)=s(m,:)+scalar_interval_prod(v(m,1),S);
        for z=2:N  
            s(m,:)=s(m,:)+scalar_interval_prod(v(m,z),state_space);
        end%l
    end% m

end%create_base_extend_prop