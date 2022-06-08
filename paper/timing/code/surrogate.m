% Version 1.0 20/06/2018
% *************************************************************************
% ********************* Surrogate data generator **************************
% *************************************************************************
% -----------------------------Copyright-----------------------------------
%
% Authors: Dmytro Iatsenko & Gemma Lancaster
% This software accompanies the article "Surrogate data for hypothesis
% testing in physical systems", G. Lancaster, D. Iatsenko, A. Pidde, 
% V. Ticcinelli and A. Stefanovska. Physics Reports, 2018.
%
% Bug reports, suggestions and comments are welcome. Please email them to
% physics-biomed@lancaster.ac.uk
%
% This is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% surrogate.m is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% See <http://www.gnu.org/licenses/>.
%
%-----------------------------Documentation--------------------------------
% EXAMPLE [surr,params]=surrogate(x, 100, 'FT', 1, 40)
% calculates 100 FT surrogates of the input signal x, which is sampled at
% 40Hz, with preprocessing on.
%
% AVAILABLE SURROGATES:
% 'RP' - Random permutation
% 'FT' - Fourier transform (see also: J. Theiler, S. Eubank, A. Longtin, 
% B. Galdrikian, J. Farmer, Testing for nonlinearity in time series: The 
% method of surrogate data, Physica D 58 (1–4) 13 (1992) 77–94).
% 'AAFT' - Amplitude adjusted Fourier transform
% 'IAAFT1' - Iterative amplitude adjusted Fourier transform with exact
% distribution (see also: T. Schreiber, A. Schmitz, Improved surrogate data for 
% nonlinearity tests, Phys. Rev. Lett. 77 (4) (1996) 635–638). 
% 'IAAFT2' - Iterative amplitude adjusted Fourier transform with exact
% spectrum
% 'CPP' - Cyclic phase permutation
% 'PPS' - Pseudo-periodic (see also: M. Small, D. Yu, R.G. Harrison, Surrogate 
% test for pseudoperiodic time series data, Phys. Rev. Lett. 87 (18) (2001) 188101.)
% 'TS' - Twin (see also: M. Thiel, M.C. Romano, J. Kurths, M. Rolfs, R. Kliegl, 
% Twin surrogates to test for complex synchronisation, Europhys. Lett. 75 (4) (2006) 535). 
% 'tshift' - Time shifted
% 'CSS' - Cycle shuffled surrogates. Require that the signal can be
% separated into distinct cycles. May require adjustment of peak finding
% parameters.  (see also: J. Theiler, On the evidence for low-dimensional chaos in an epileptic 
% electroencephalogram, Phys. Lett. A 196 (1) (1995) 335–341). 
%
%
% INPUT:
% sig - time series for which to calculate surrogate(s)
% Input sig should be the original time series, or phase for CPP.
% For surrogates requiring embedding, the delay tau and dimension D are
% calculated automatically using false nearest neighbours and first 0
% autocorrelation, respectively.
% N - number of surrogates to calculate
% method - surrogate type, choose from one of the strings above
% pp - preprocessing on (1) or off (0) (match beginning and end and first
% derivatives)
%
% varargin options
% if method = 'FT', random phases can be input and output, to preserve for
% multivariate surrogates for example
% if method = 'PPS' or 'TS', embedding dimension can be entered beforehand instead of
% being estimated, if it is to be kept the same for all surrogates
% if method = 'CSS', minimum peak height and minimum peak distance can be
% entered to ensure correct peak detection for separation of cycles.
%
% OUTPUT:
% surr - surrogate data
% params - parameters from the generation, including truncation locations
% if preprocessed and runtime.

function [surr,params]=surrogate(sig, N, method, pp, fs, varargin)

origsig=sig;
params.origsig=origsig;
params.method=method;
params.numsurr=N;
params.fs=fs;
z=clock;

%%%%%%% Preprocessing %%%%%%%
if pp==1
    [sig,time,ks,ke]=preprocessing(sig,fs);
else
    time=linspace(0, length(sig)/fs,length(sig));
end
L=length(sig);
L2=ceil(L/2);
if pp==1
    params.preprocessing='on';
    params.cutsig=sig;
    params.sigstart=ks;
    params.sigend=ke;
else
    params.preprocessing='off';
end
params.time=time;

%%%%%%% Random permutation (RP) surrogates %%%%%%%
if strcmp(method,'RP') 
    surr=zeros(N,length(sig));
    for k=1:N
        surr(k,:)=sig(randperm(L));
    end    


%%%%%%% Fourier transform (FT) surrogate %%%%%%%
elseif strcmp(method,'FT')
    
    a=0; b=2*pi;
    if nargin>5 
        eta=varargin{1};
    else
        eta=(b-a).*rand(N,L2-1)+a; % Random phases
    end
    ftsig=fft(sig); % Fourier transform of signal
    ftrp=zeros(N,length(ftsig));

    ftrp(:,1)=ftsig(1);
    F=ftsig(2:L2);
    F=F(ones(1,N),:);
    ftrp(:,2:L2)=F.*(exp(1i*eta));
    ftrp(:,2+L-L2:L)=conj(fliplr(ftrp(:,2:L2)));

    surr=ifft(ftrp,[],2);
    
params.rphases=eta;    
    
    

%%%%%%% Amplitude adjusted Fourier transform surrogate %%%%%%%    
elseif strcmp(method,'AAFT')
    
    a=0; b=2*pi;
    eta=(b-a).*rand(N,L2-1)+a; % Random phases
    [val,ind]=sort(sig);
    rankind(ind)=1:L;    % Rank the locations

    gn=sort(randn(N,length(sig)),2); % Create Gaussian noise signal and sort
    for j=1:N
        gn(j,:)=gn(j,rankind); % Reorder noise signal to match ranks in original signal
    end

    ftgn=fft(gn,[],2);
    F=ftgn(:,2:L2);

    surr=zeros(N,length(sig));
    surr(:,1)=gn(:,1);
    surr(:,2:L2)=F.*exp(1i*eta);
    surr(:,2+L-L2:L)=conj(fliplr(surr(:,2:L2)));
    surr=(ifft(surr,[],2));

    [~,ind2]=sort(surr,2); % Sort surrogate
    rrank=zeros(1,L);
    for k=1:N
        rrank(ind2(k,:))=1:L;
        surr(k,:)=val(rrank);
    end
    
      
    
    
%%%%%%% Iterated amplitude adjusted Fourier transform (IAAFT-1) with exact distribution %%%%%%%   
elseif strcmp(method,'IAAFT1')
    maxit=1000;
    [val,ind]=sort(sig);  % Sorted list of values
    rankind(ind)=1:L; % Rank the values

    ftsig=fft(sig);
    F=ftsig(ones(1,N),:);
    surr=zeros(N,L);
     
    for j=1:N
        surr(j,:)=sig(randperm(L)); % Random shuffle of the data
    end

    it=1;
    irank=rankind;
    irank=irank(ones(1,N),:);
    irank2=zeros(1,L);
    oldrank=zeros(N,L);
    iind=zeros(N,L);
    iterf=zeros(N,L);

    while max(max(abs(oldrank-irank),[],2))~=0 && it<maxit
        go=max(abs(oldrank-irank),[],2);
        [~,inc]=find(go'~=0);

            oldrank=irank;
            iterf(inc,:)=real(ifft(abs(F(inc,:)).*exp(1i*angle(fft(surr(inc,:),[],2))),[],2));      
    
            [~,iind(inc,:)]=sort(iterf(inc,:),2);
                for k=inc
                    irank2(iind(k,:))=1:L;
                    irank(k,:)=irank2;
                    surr(k,:)=val(irank2);
                end
    
            it=it+1;        
    end

    
%%%%%%% Iterated amplitude adjusted Fourier transform (IAAFT-2) with exact spectrum %%%%%%%    
elseif strcmp(method,'IAAFT2')
    maxit=1000;
    [val,ind]=sort(sig);  % Sorted list of values
    rankind(ind)=1:L; % Rank the values

    ftsig=fft(sig);
    F=ftsig(ones(1,N),:);
    surr=zeros(N,L);
     
    for j=1:N
        surr(j,:)=sig(randperm(L)); % Random shuffle of the data
    end

    it=1;
    irank=rankind;
    irank=irank(ones(1,N),:);
    irank2=zeros(1,L);
    oldrank=zeros(N,L);
    iind=zeros(N,L);
    iterf=zeros(N,L);

    while max(max(abs(oldrank-irank),[],2))~=0 && it<maxit
        go=max(abs(oldrank-irank),[],2);
        [~,inc]=find(go'~=0);

            oldrank=irank;
            iterf(inc,:)=real(ifft(abs(F(inc,:)).*exp(1i*angle(fft(surr(inc,:),[],2))),[],2));      
    
            [~,iind(inc,:)]=sort(iterf(inc,:),2);
                for k=inc
                    irank2(iind(k,:))=1:L;
                    irank(k,:)=irank2;
                    surr(k,:)=val(irank2);
                end
    
            it=it+1;
        
    end
    surr=iterf;
    
    
    
%%%%%%% Cyclic phase permutation (CPP) surrogates %%%%%%%    
elseif strcmp(method,'CPP')
    
phi=wrapTo2Pi(sig);

pdiff=phi(2:end)-phi(1:end-1);
locs=find(pdiff<-pi);
parts=cell(length(locs)-1);
for j=1:length(locs)-1
    tsig=phi(locs(j)+1:locs(j+1));
    parts{j}=tsig;    
end

st=phi(1:locs(1));
en=phi(locs(j+1)+1:end);
surr=zeros(N,L);
for k=1:N
    surr(k,:)=unwrap(horzcat(st,parts{randperm(j)},en));
    
end


%%%%%%% Pseudo-periodic surrogates (PPS) %%%%%%%
elseif strcmp(method,'PPS')
    
% Embedding of original signal
if nargin>5 
        m=varargin{1};
        [sig,tau]=embedsig(sig,'DimAlg',m); 
        
    else
        [sig,tau]=embedsig(sig,'DimAlg','fnn'); 
        m=size(sig);
        m=m(1);
end

L=length(sig);
L2=ceil(L/2);
time=linspace(0,length(sig)/fs,length(sig));
params.embed_delay=tau;
params.embed_dim=m;
params.embed_sig=sig;

% % Find the index of the first nearest neighbour from the first half of the
% % embedded signal to its last value to avoid cycling near last value

for k=1:L
        matr=max(abs(sig(:,:)-sig(:,k)*ones(1,L)));
        [ssig(k),mind(k)]=min(matr(matr>0));
end

[~,pl]=min(matr(1:round(L/2))); rho=0.7*mean(ssig); clear mind ssig;
parfor x=1:N
kn=randi(L,1); % Choose random starting point

for j=1:L % Length of surrogate is the same as the embedded time series
    if kn==L
    kn=pl;
    end
    kn=kn+1; % Move forward from previous kn
    surr(x,j)=sig(1,kn); % Set surrogate to current value for kn (choose first component, can be any)
    sigdist=max(abs(sig(:,:)-(sig(:,kn)+randn*rho)*ones(1,L))); % Find the maximum 
    % distance between each point in the original signal and the current
    % values with noise added
    [~,kn]=min(sigdist); % Find nearest point

end
end



% %%%%%%% Twin surrogates %%%%%%%
elseif strcmp(method,'TS') % 
    
% Embedding of original signal
if nargin>5 
        m=varargin{1};
        [sig,tau]=embedsig(sig,'DimAlg',m); 
        
    else
        [sig,tau]=embedsig(sig,'DimAlg','fnn'); 
        m=size(sig);
        m=m(1);
end
L=length(sig);
L2=ceil(L/2);
time=linspace(0,length(sig)/fs,length(sig));
params.embed_delay=tau;
params.embed_dim=m;
params.embed_sig=sig;
    
    dL=L;
    alpha=0.1;
    
    Rij=zeros(L,L);
    for k=2:L
        Rij(k,1:k-1)=max(abs(sig(:,1:k-1)-sig(:,k)*ones(1,k-1)));
    end
    Rij=Rij+Rij';
    [~,pl]=min(Rij(1:round(L/2),L));
    Sij=sort(Rij(:)); delta=Sij(round(alpha*L^2)); clear Sij;
    Rij(Rij<delta)=-1; Rij(Rij>delta)=0; Rij=abs(Rij);
    
    ind=cell(L,1); eln=zeros(L,1); twind=1:L;
    remp=1; % remaining points
    while ~isempty(remp)
        twn=remp(1);
        ind{twn}=remp(max(abs(Rij(:,remp)-Rij(:,twn)*ones(1,numel(remp))))==0);
        ind(ind{twn})=ind(twn);
        eln(ind{twn})=length(ind{twn});
        twind(ind{twn})=0;
        remp=twind(twind>0);
    end
    clear Rij twind;
    
    for sn=1:N
        kn=randi(L,1)-1;
        for j=1:dL
            kn=kn+1;
            surr(sn,j)=sig(1,kn);
            kn=ind{kn}(randi(eln(kn),1));
            if kn==L
                kn=pl;
            end
        end
    end


    
%%%%%%% Time-shifted surrogates %%%%%%%
elseif strcmp(method,'tshift') 
    %nums=randperm(L);
    for sn=1:N
        startp=randi(L-1,1);%nums(sn);%
        surr(sn,:)=horzcat(sig(1+startp:L),sig(1:startp));
    end
%params.tshifts=nums(1:N);  
    



%%%%%%% Cycle shuffled surrogates
elseif strcmp(method,'CSS')
    
    if nargin>5 
        MPH=varargin{1}; % Minimum heak height
        MPD=varargin{2}; % Minimum peak distance
    else
        MPH=0;
        MPD=fs;
    end
    
    [~,I]=findpeaks(sig,'MinPeakHeight',MPH,'MinPeakDistance',MPD);

    st=sig(1:I(1)-1);
    en=sig(I(end):end);

for j=1:length(I)-1
    parts{j}=sig(I(j):I(j+1)-1);    
end

for k=1:N
    surr(k,:)=unwrap(horzcat(st,parts{randperm(j)},en));
    
end

end

params.runtime=etime(clock,z);
params.type=method;


end




function [cutsig,t2,kstart,kend]=preprocessing(sig,fs)
sig=sig-mean(sig);
t=linspace(0,length(sig)/fs,length(sig));
L=length(sig);
p=10; % Find pair of points which minimizes mismatch between p consecutive 
%points and the beginning and the end of the signal

K1=round(L/100); % Proportion of signal to consider at the beginning
k1=sig(1:K1);
K2=round(L/10);  % Proportion of signal to consider at the end
k2=sig(end-K2:end);

% Truncate to match start and end points and first derivatives
if length(k1)<=p
    p=length(k1)-1;
else
end
d=zeros(length(k1)-p,length(k2)-p);

for j=1:length(k1)-p
    for k=1:length(k2)-p
        d(j,k)=sum(abs(k1(j:j+p)-k2(k:k+p)));
    end
end

[v,I]=min(abs(d),[],2);
[~,I2]=min(v); % Minimum mismatch

kstart=I2;
kend=I(I2)+length(sig(1:end-K2));
cutsig=sig(kstart:kend); % New truncated time series
t2=t(kstart:kend); % Corresponding time

end


