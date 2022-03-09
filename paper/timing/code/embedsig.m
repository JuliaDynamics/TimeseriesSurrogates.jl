%============================Signal embedding==============================
% Version 1.00 stable
%------------------------------Requirements--------------------------------
% requires boxdim.m and corrdim.m (the latter only if using
% 'DimAlg'='corrdim', see Documentation below).
%
%-------------------------------Copyright----------------------------------
%
% Author: Dmytro Iatsenko
%------------------------------Documentation-------------------------------
%
% [esig,Optional:tau,ds]=embedsig(sig,Optional:'PropertyName',PropertyValue);
%
% OUTPUT:
% esig: [D x (L-(D-1)*tau)] matrix
%        - the embedded signal, with [D=size(esig,1)] being embedded
%          dimension, [L] is the original signal length, and [tau] denotes
%          embedding lag in samples.
% tau: positive integer value
%        - embedding lag (time-shift) in samples
% ds: [1 x D] vector
%        - calculated values of discriminating statistics for each
%          tested embedding dimension (proportion of false nearest
%          neighbors for 'fnn' algorithm, the corresponding dimensions for
%          'boxdim', 'boxdim-q' and 'corrdim' approaches, see property
%          'DimAlg' below).
%
% INPUT:
% sig: [1 x L] or [L x 1] vector
%        - the original signal which to embed
%
% Properties: ({{...}} denotes default)
% 'LagAlg':{{'autocorr'}}|'mutinf'|value
%        - the algorithm for determining the embedding lag:
%          'autocorr' - as the time of the first zero crossing of
%          the autocorrelation function (calculated for the detrended
%          signal, obtained by subtracting 3rd order polynomial fit);
%          'mutinf' - based on mutual information minimum (warning: has
%          O(N^2) computational cost); alternatively, you can just specify
%          the value of embedding lag (in samples), e.g. found by some
%          other algorithm.
% 'DimAlg':{{'boxdim'}}|'boxdim-q'|'corrdim'|'fnn'|'fnn-R'|'fnn-R-m'|'hilbert'|value
%        - the algorithm for determining embedding dimension:
%          'fnn' - false nearest neighbors;
%          'corrdim' - as the dimension exceeding by more than one the
%          Grassberger-Procaccia correlation dimension calculated for it
%          ( using function corrdim(esig), where esig is the current
%          version of the embedded signal );
%          'boxdim' - same as previous, but instead of correlation
%          dimension, computation of which might be quite slow, uses
%          capacity dimension calculated quickly using box-counting
%          algorithm ( using boxdim(esig) );
%          'boxdim-q' (e.g. 'boxdim-1') - same as previous, but uses
%          generalized Renyi dimension of the order [q], also
%          calculated by box-counting algorithm ( boxdim(esig,q) )
%          ('boxdim' is the same as 'boxdim-0');
%          'fnn-R' (e.g. 'fnn-10') and 'fnn-R-m' (e.g. 'fnn-10-0.1') - the
%          same as 'fnn', but with specified threshold [R] for regarding
%          neighbors as false and the maximum percentage [m] of the false
%          neighbors allowed (the usual 'fnn' is equivalent to 'fnn-0.1'
%          and 'fnn-20-0.01');
%          'hilbert' - returns as embedded signal simply 2xL matrix with
%          first and second rows being respectively real and imaginary
%          parts of the analytic signal transform of  the signal [sig]
%          (can be sometimes useful for strongly periodic time-series).
%          Alternatively, one can just specify the embedding dimension as
%          [value], e.g. set 'DimAlg' to 3 to embed in 3-dimensional space.
% 'EstAlg':same as [method] in boxdim.m and corrdim.m
%        - the algorithm for estimating the box dimension (e.g. 'PolyFit-3')
%          if 'DimAlg'='boxdim' or 'boxdim-q', or Grassberger-Procaccia
%          correlation dimension (e.g. 'Takens') if 'DimAlg'='corrdim',
%          see Documentation of boxdim.m and corrdim.m, respectively.
% 'Display':{{'on'}}|'off'
%        - specifies to display or not the progress information.
%
% NOTE: One can alternatively pass the structure with the properties as the
% second argument, e.g. /opt.LagAlg='mutinf'; embedsig(sig,opt);/. If the
% other properties are specified next, they override those in the
% structure, e.g. /embedsig(sig,opt,'LagAlg','autocorr');/ will always use
% autocorrelation algorithm to determine the embedding time-lag.
%
%--------------------------------------------------------------------------

function [esig,varargout] = embedsig(sig,varargin)

L=length(sig); sig=sig(:)';

%Default parameters
LagAlg='autocorr'; DimAlg='boxdim'; DispMode='on'; EstAlg=[];
%Update if user defined
vst=1;
if nargin>1 && isstruct(varargin{1})
    copt=varargin{1}; vst=2;
    if isfield(copt,'Display'), cvv=copt.Display; if ~isempty(cvv), DispMode=cvv; end, end
    if isfield(copt,'LagAlg'), cvv=copt.LagAlg; if ~isempty(cvv), LagAlg=cvv; end, end
    if isfield(copt,'DimAlg'), cvv=copt.DimAlg; if ~isempty(cvv), DimAlg=cvv; end, end
    if isfield(copt,'EstAlg'), cvv=copt.EstAlg; if ~isempty(cvv), EstAlg=cvv; end, end
end
for vn=vst:2:nargin-1
    if strcmpi(varargin{vn},'Display'), if ~isempty(varargin{vn+1}), DispMode=varargin{vn+1}; end
    elseif strcmpi(varargin{vn},'LagAlg'), if ~isempty(varargin{vn+1}), LagAlg=varargin{vn+1}; end
    elseif strcmpi(varargin{vn},'DimAlg'), if ~isempty(varargin{vn+1}), DimAlg=varargin{vn+1}; end
    elseif strcmpi(varargin{vn},'EstAlg'), if ~isempty(varargin{vn+1}), EstAlg=varargin{vn+1}; end
    else
        error(['There is no Property "',varargin{vn},'" (which is ',num2str(1+(vn-1)/2,'%d'),...
            '''th out of ',num2str(ceil((nargin-1-1)/2),'%d'),' specified)']);
    end
end

%Estimate the embedding time-lag
if strcmpi(DimAlg,'hilbert')
    tau=0;
elseif strcmpi(LagAlg,'autocorr')
    if ~strcmpi(DispMode,'off'), fprintf('Estimating the embedding lag from Autocorrelation: '); end
    X=(1:length(sig))'; FM=ones(length(X),4); for pn=1:3, CX=X.^pn; FM(:,pn+1)=(CX-mean(CX))/std(CX); end
    csig=sig(:)-FM*(pinv(FM)*sig(:)); acorr=ifft(abs(fft(csig)).^2);
    tau=find(acorr(1:end-1)>=0 & acorr(2:end)<=0,1,'first');
    if ~strcmpi(DispMode,'off'), fprintf('tau = %d samples \n',tau); end
elseif strcmpi(LagAlg,'mutinf')
    if ~strcmpi(DispMode,'off'), fprintf('Estimating the embedding lag from Mutual Information: '); end
    NB=round(exp(0.636)*(L-1)^(2/5)); ss=(max(sig)-min(sig))/NB/10; %optimal number of bins and small shift
    bb=linspace(min(sig)-ss,max(sig)+ss,NB+1); bc=(bb(1:end-1)+bb(2:end))/2; bw=mean(diff(bb)); %bins boundaries, centers and width
    mi=zeros(1,L)*NaN; %mutual information
    for kn=0:L-1
        sig1=sig(1:L-kn); sig2=sig(kn+1:L);
        %Calculate probabilities
        prob1=zeros(NB,1); bid1=zeros(1,L-kn);
        prob2=zeros(NB,1); bid2=zeros(1,L-kn);
        jprob=zeros(NB,NB); jid=zeros(1,L-kn);
        for tn=1:L-kn
            cid1=1+floor(0.5+(sig1(tn)-bc(1))/bw); bid1(tn)=cid1; prob1(cid1)=prob1(cid1)+1;
            cid2=1+floor(0.5+(sig2(tn)-bc(1))/bw); bid2(tn)=cid2; prob2(cid2)=prob2(cid2)+1;
            jprob(cid1,cid2)=jprob(cid1,cid2)+1; jid=cid1+NB*(cid2-1);
        end
        prob1=prob1/(L-kn); prob2=prob2/(L-kn); jprob=jprob/(L-kn);
        prob1=prob1(bid1); prob2=prob2(bid2); jprob=jprob(jid);
        %Estimate mutual information
        mi(kn+1)=sum(jprob.*log2(jprob./(prob1.*prob2)));
        %Stop if minimum occured
        if kn>0 && mi(kn+1)>mi(kn), tau=kn; break; end
    end
    if ~strcmpi(DispMode,'off'), fprintf('tau = %d samples \n',tau); end
else
    tau=LagAlg;
end
if nargout>1, varargout{1}=tau; end

%Estimate the embedding dimension
if isnumeric(DimAlg)
    D=DimAlg; esig=zeros(D,L-(D-1)*tau); for dn=1:D, esig(dn,:)=sig(1+(dn-1)*tau:L-(D-dn)*tau); end
    if nargout>2, varargout{2}=[]; end
elseif strcmpi(DimAlg,'hilbert')
    asig=fft(sig); asig(ceil(0.5+L/2):end)=0; asig=2*ifft(asig);
    esig=[real(asig);imag(asig)];
    if nargout>2, varargout{2}=[]; end
elseif ~isempty(strfind(DimAlg,'fnn'))
    if ~strcmpi(DispMode,'off')
        fprintf('Estimating the embedding dimension by False Nearest Neighbors (FNN) scheme: \n');
        fprintf('embedding dimension - %%%% of FNN: ');
    end
    
    RT=20; mm=0.01; spos=strfind(DimAlg,'-');
    if length(spos)==1, RT=str2double(DimAlg(spos+1:end)); end
    if length(spos)==2, RT=str2double(DimAlg(spos(1)+1:spos(2)-1)); mm=str2double(DimAlg(spos(2)+1:end)); end
    
    pfnn=1; d=1; esig=sig;
    while pfnn(end)>mm
        [NNid,NNdist]=idnearest(esig(:,1:end-tau));
        d=d+1; EL=L-(d-1)*tau;
        esig=zeros(d,EL); for dn=1:d, esig(dn,:)=sig(1+(dn-1)*tau:L-(d-dn)*tau); end
        %Check false nearest neighbors
        FNdist=zeros(1,EL);
        for tn=1:size(esig,2), FNdist(tn)=sqrt(sum((esig(:,tn)-esig(:,NNid(tn))).^2)); end
        pfnn=[pfnn,length(find((FNdist.^2-NNdist.^2)>(RT^2)*NNdist.^2))/EL];
        if ~strcmpi(DispMode,'off'), fprintf('%d - %0.2f%%; ',d-1,100*pfnn(end)); end
    end
    if ~strcmpi(DispMode,'off'), fprintf('\n'); end
    if nargout>2, varargout{2}=pfnn; end
    
    %Final estimates
    D=d-1; esig=zeros(D,L-(D-1)*tau); for dn=1:D, esig(dn,:)=sig(1+(dn-1)*tau:L-(D-dn)*tau); end
elseif ~isempty(strfind(DimAlg,'corrdim'))
    if ~strcmpi(DispMode,'off')
        fprintf('Estimating the embedding dimension using Correlation Dimension: \n');
        fprintf('embedding dimension - correlation dimension: ');
    end
    
    cdim=1; d=0;
    while cdim(end)+1>d
        d=d+1; EL=L-(d-1)*tau;
        esig=zeros(d,EL); for dn=1:d, esig(dn,:)=sig(1+(dn-1)*tau:L-(d-dn)*tau); end
        cdim=[cdim,corrdim(esig,[],EstAlg)]; %correlation dimension
        if ~strcmpi(DispMode,'off'), fprintf('%d - %0.2f; ',d,cdim(end)); end
    end
    if ~strcmpi(DispMode,'off'), fprintf('\n'); end
    if nargout>2, varargout{2}=cdim; end
    
elseif ~isempty(strfind(DimAlg,'boxdim'))
    q=0; spos=strfind(DimAlg,'-'); if ~isempty(spos), q=str2double(DimAlg(spos(1)+1:end)); end
    if ~strcmpi(DispMode,'off')
        fprintf(['Estimating the embedding dimension using Renyi Dimension of order ',num2str(q),' (box-counting algorithm): \n']);
        fprintf('embedding dimension - Renyi dimension: ');
    end
    
    bdim=1; d=0;
    while bdim(end)+1>d
        d=d+1; EL=L-(d-1)*tau;
        esig=zeros(d,EL); for dn=1:d, esig(dn,:)=sig(1+(dn-1)*tau:L-(d-dn)*tau); end
        bdim=[bdim,boxdim(esig,[],q,EstAlg)];
        if ~strcmpi(DispMode,'off'), fprintf('%d - %0.2f; ',d,bdim(end)); end
    end
    if ~strcmpi(DispMode,'off'), fprintf('\n'); end
    if nargout>2, varargout{2}=bdim; end
    
end


end


%Function for finding the indices of the nearest neighbors and distances between them
function [NNid,NNdist]=idnearest(esig)

[D,L]=size(esig); r0=median(sqrt(sum(diff(esig,1,2).^2,1)));
NNid=zeros(1,L); NNdist=zeros(1,L)*NaN;

msig=min(esig,[],2); jid=1+round(-0.5+(esig-msig*ones(1,L))/r0); jid(jid<1)=1; %d-dimensional box indices for each point
cid=cell(4,1); kid=cell(4,1); dind=cell(4,1); %different indices: sorted, sort indices, indices of change
UL=zeros(4,1); XX=zeros(4,1); %numbers of unique boxes and relative computational costs
%Linear indices
Nb=max(jid,[],2); Kb=cumprod(Nb); %number of boxes over each dimension and their cumulative product
ccid=jid(1,:); for dn=2:D, ccid=ccid+Kb(dn-1)*(jid(dn,:)-1); end
[cid{1},kid{1}]=sort(ccid); dind{1}=find(diff(cid{1})>0.5); UL(1)=1+length(dind{1});
XX(1)=(-1+3^D)*(2+(UL(1)/L)*log2(UL(1))/D+L/UL(1));
%One dimension indices
ccid=cell(D,1); ckid=cell(D,1); cdind=cell(D,1); CUL=zeros(D,1);
for dn=1:D, [ccid{dn},ckid{dn}]=sort(jid(dn,:)); cdind{dn}=find(diff(ccid{dn})>0.5); CUL(dn)=1+length(cdind{dn}); end
[UL(2),mdn]=min(CUL); cid{2}=ccid{mdn}; kid{2}=ckid{mdn}; dind{2}=cdind{mdn}; clear ccid ckid cdind;
XX(2)=2*L/UL(2);
%Maximum indices
[cid{3},kid{3}]=sort(max(jid,[],1)); dind{3}=find(diff(cid{3})>0.5); UL(3)=1+length(dind{3});
XX(3)=2*L/UL(3);
%Summary indices
[cid{4},kid{4}]=sort(sum(jid,1)); dind{4}=find(diff(cid{4})>0.5); UL(4)=1+length(dind{4});
XX(4)=2*D*L/UL(4);

%Determine the optimal strategy
[~,idd]=min(XX); cid=cid{idd}; kid=kid{idd}; dind=dind{idd}; UL=UL(idd);
uid=cid([1,dind+1]); mid1=[1,dind+1]; mid2=[dind,L]; %unique linear box indices and corresponding ranges for sorted points numbers
jid=jid(:,kid); esig=esig(:,kid); rid=1:L; rid(kid)=1:L; %rearrange all indices plus remember recovery indices

if idd==1 %use full-dimensional boxes
    tbid=zeros(1,L); cadd=[0,1,-1]; cjid=zeros(D,1);
    for bn=1:UL
        cmid1=mid1(bn); cmid2=mid2(bn);
        inum=cmid2-cmid1+1; tbid(1:inum)=cmid1:cmid2; cesig=esig(:,cmid1:cmid2);
        
        tjid=jid(:,cmid1);
        for cn=2:3^D
            bb=cn; for dn=1:D, cid=1+mod(bb-1,3); bb=(bb-mod(bb,3))/3; cjid(dn)=tjid(dn)+cadd(cid); end
            clid=cjid(1); for dn=2:D, clid=clid+Kb(dn-1)*(cjid(dn)-1); end
            %Search for points in the current box
            if clid~=uid(bn)
                if clid<uid(end)
                    cq1=1; cq2=UL;
                    while cq2-cq1>1
                        cq=ceil((cq1+cq2)/2);
                        if uid(cq)==clid, cq1=cq; cq2=cq; elseif uid(cq)>clid, cq2=cq; else cq1=cq; end
                    end
                    if cq2-cq1==0, cq=cq1; else cq=0; end
                elseif clid==uid(end), cq=UL;
                else cq=0;
                end
                %Find the indices in the current box
                if cq>0
                    CL=mid2(cq)-mid1(cq)+1;
                    tbid(inum+1:inum+CL)=mid1(cq):mid2(cq);
                    inum=inum+CL;
                end
            end
        end
        
        %Assign all
        if inum>1
            itbid=tbid(1:inum);
            for tn=1:cmid2-cmid1+1
                [NNdist(cmid1+tn-1),cidnn]=min(sqrt(sum((cesig(:,tn)*ones(1,inum-1)-esig(:,itbid([1:tn-1,1+tn:inum]))).^2,1)));
                if cidnn<tn, NNid(cmid1+tn-1)=itbid(cidnn); else NNid(cmid1+tn-1)=itbid(cidnn+1); end
            end
        end
    end
    
else %use one-dimensional boxes
    dd=1; if idd==4, dd=D; end %number of bins ahead
    for bn=1:UL
        sbn=bn-dd; if sbn<1, sbn=1; end
        ebn=bn+dd; if ebn>UL, ebn=UL; end
        for tn=mid1(bn):mid2(bn)
            [NNdist(tn),cidnn]=min(sqrt(sum((esig(:,tn)*ones(1,mid2(ebn)-mid1(sbn))-esig(:,[mid1(sbn):tn-1,tn+1:mid2(ebn)])).^2,1)));
            if cidnn<tn-mid1(sbn)+1, NNid(tn)=mid1(sbn)+cidnn-1; else NNid(tn)=mid1(sbn)+cidnn; end
        end
    end
end

%Refine the neighbors which might be not found correctly
idch=find(isnan(NNdist) | NNdist>r0);
for kn=1:length(idch)
    ctn=idch(kn);
    [NNdist(ctn),cidnn]=min(sqrt(sum((esig(:,ctn)*ones(1,L-1)-esig(:,[1:ctn-1,ctn+1:end])).^2,1)));
    if cidnn<ctn, NNid(ctn)=cidnn; else NNid(ctn)=cidnn+1; end
end

%Recover the original order
NNdist=NNdist(rid); NNid=kid(NNid); NNid=NNid(rid);

end
