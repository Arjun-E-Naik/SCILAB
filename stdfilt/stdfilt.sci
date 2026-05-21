function J = stdfilt(I,nhood)

    [lhs,rhs]=argn(0);

    if rhs<1 then
        error("stdfilt: Wrong number of input arguments.");
    end

    if rhs<2 then
        nhood=ones(3,3);
    end

    I=double(I);

    [r,c]=size(nhood);

    pr=floor(r/2);
    pc=floor(c/2);

    N=sum(nhood);

    if N<=1 then
        J=zeros(I);
        return;
    end

    [m,n]=size(I);

    // symmetric padding
    Ipad=I;

    if pr>0 then
        Ipad=[I(pr:-1:1,:);
              Ipad;
              I(m:-1:m-pr+1,:)];
    end

    if pc>0 then
        Ipad=[Ipad(:,pc:-1:1),...
              Ipad,...
              Ipad(:,n:-1:n-pc+1)];
    end

    I2=Ipad.*Ipad;

    S1=conv2(Ipad,nhood,'valid');
    S2=conv2(I2,nhood,'valid');

    S1sq=S1.*S1;

    V=(S2-S1sq/N)/(N-1);

    J=sqrt(max(V,0));

endfunction