function out=wavelet_monitor(decomp_signal, formula, wvlt_basis, state_space)
    %This function will peform monitoring of a Jth level decomposition in
    %the wavelet domain. 
    
    %it will obtain phi_{-j} through phi_{-1} and similar for eta

    %decomp_signal takes in the decomposed signal as a cell array. The
    %structure should be as follows: the first entry should be the d_{-1},
    %followed by d_{-2}...x_{-J}

    %formula is the formula of interest, structured as in MRA_DT_STL

    %wvlt_basis is the full Jth level wavelet basis structured as a cell
    %array. It will be in order of {W_{-1},W_{-2}...,V_{-J}}, 

    %wvlt_basis MUST be the SAME basis used to find decomp_dignal. 
    %wvlt_basis and decomp_signal must be of the same length and level of
    %decompostion. So If wvlt_basis is a pth stage basis, decomp_signal
    %needs to be a pth level decomposition of the original signal.

    %% Initialization
    J=length(decomp_signal)-1; %Highest level of decomp.
    out=1; %If all low resolution formulas are satisfied return true.

    %% Find decomposed formulas
    % Here we need repeated calls of MRA_DT_STL. Start with two cell
    % arrays: one for detail formulas and one for approximation at each
    % level

    lr_formulas{J}=[];
    %set first V for the iteration. Allows for updating as we go.
    V=wvlt_basis{end};

    for i=1:J 
        W=wvlt_basis{end-i};
        lr_formulas{i}=MRA_DT_STL(formula, V, W, state_space);
        V=[V,W];
    end %i



    %% Now monitor. 

    current_approx=decomp_signal{end}; %Initialize the current x_{-j}, as
                                       %this changes dynamically throughout
                                       %the loop below. 
    for i=1:J
        
        %Approximation x_{-j}
        if ~recursive_monitor(current_approx, lr_formulas{i}, 'a', 0)
            fprintf('approximation at scale %d does not satisfy the formula\n', i)
            out=0;
            break
        end %if


        %Details d_{-j}
        if ~recursive_monitor(decomp_signal{end-i}, lr_formulas{i}, 'd', 0)
            fprintf('details at scale %d does not satisfy the formula\n', i)
            out=0;
            break       
        end%if

        %Construct x_{-j+1} for checking in the next iteration.
        current_approx=current_approx+decomp_signal{end-i};
    end%i


end%wavelet monitor