function Basis=create_basis(wvlt,N,j,VW)
%
%wvlt
%   String of wavelet name. Accepts '' or string of a valid wavelet name.
%   The filter chosen should have len<=N. If len>N, sym2
%N
%   Length of signal.
%j
%   Level of decomposition
%VW
%   accepts '', 'V', or 'W'. Choose 'V' for approximation, 'W' for details.

if isempty(wvlt)
    wvlt='sym2';
end%if

if isempty(VW)
    VW='V';
end%if


%initialize B
Basis=[];

if VW=='W'
    g=zeros(N,1);
    f=zeros(N,1);
    %Get some decomposition, only so that we can get at the wavelets. 
    %Resulting dwtFilters.LoD are independent of any input other than wvlt
    dec=mdwtdec('c',ones(1,32),1,wvlt);
    LoD=dec.dwtFilters.LoD';
    HiD=dec.dwtFilters.HiD;
    
    %recall g1=u1. 
    g(1:length(LoD))=LoD;
    f(1:length(HiD))=HiD;
    
    %Construct g_i and f_i needed to create V/W
    if j>1
        for qq=2:j
            ui=wave_level(g(:,1),qq); %constuct the ith level filter from 
            vi=wave_level(f(:,1),qq); %from the first level
            
            ui_up=myupsample(ui,qq-1);%upsample qq-i times
            vi_up=myupsample(vi,qq-1);
            
            g_i=my_conv(g(:,qq-1),ui_up);%convolve with the previous g
            f_i=my_conv(g(:,qq-1),vi_up);%my conv because MATLAB conv()
                                         %zero pads
            g=[g,g_i]; %add it to the list
            f=[f,f_i];
        end%i
    end%if

    %Build up the rotations of f to create the basis for the details.
    for kk=0:N/2^j-1
        Basis=[Basis,circshift(f(:,end),2^j*kk)];
    end%kk
    
elseif VW=='V'
    g=zeros(N,1);
    %Get some decomposition, only so that we can get at the wavelets. 
    %Resulting dwtFilters.LoD are independent of any input other than wvlt
    dec=mdwtdec('c',ones(1,32),1,wvlt);
    LoD=dec.dwtFilters.LoD';
    
    %recall g1=u1.
    g(1:length(LoD))=LoD;
    
    %now g_p=conv(g_{p-1},U^{p-1}(u_p)
    if j>1
        for qq=2:j
            %construct g_i
            ui=wave_level(g(:,1),qq); %constuct the ith level filter from 
                                      %from the first level
                                      
            ui_up=myupsample(ui,qq-1);%upsample qq-i times
            
            g_i=my_conv(g(:,qq-1),ui_up);%convolve with the previous g
                                         %my conv because MATLAB conv()
                                         %zero pads
            g=[g,g_i]; %add it to the list
        end%i
    end%if

    for kk=0:N/2^j-1
        Basis=[Basis,circshift(g(:,end),2^j*kk)];
    end%kk
    
else
    disp('Invalid value for VW')
end%if
    

    
function output=myupsample(z,num)
    %z 
    %   [] with length N.
    %num
    %   integer number of upsamples
    %output
    %   z upsampled such that output is a column vector of length 2N
    Uz=zeros(length(z)*2^num,1);
    for i=1:length(Uz)
        if mod(i,2^num)==0
        Uz(i)=z((i)/2^num);
        else
        Uz(i)=0;
        end%if
    end%i
    output=circshift(Uz,1-2^(num));
end%myupsample

function output=wave_level(u1,level)
    N=length(u1);
    ulvl=zeros(N/2^(level-1),1);

    for n=1:N/2^(level-1)
        for k=1:2^(level-1)
            ulvl(n)=ulvl(n)+u1(n+(k-1)*N/2^(level-1));
        end %end k
    end%n
    output=ulvl;
end%wave_level
    
function f=my_conv(z,w)
    N=length(z);
    out=zeros(N,1);
    for m=0:N-1
        for n=0:N-1
            if m+1-n>=1
                out(m+1)=out(m+1)+z(m+1-n)*w(n+1); 
            else
                out(m+1)=out(m+1)+z(N+m+1-n)*w(n+1);
            end%if
        end%n
    end%m
    f=out;
    end%my_conv
end%function
    