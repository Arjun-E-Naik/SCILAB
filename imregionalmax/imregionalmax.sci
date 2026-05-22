function BW = immaximas(I, conn)

    [lhs,rhs]=argn(0);

    if rhs<1 then
        error("immaximas: Input image required");
    end

    if rhs<2 then
        conn=8;
    end

    if conn~=4 & conn~=8 then
        error("Connectivity must be 4 or 8");
    end

    I=double(I);

    [rows,cols]=size(I);

    // Marker image
    J=I-1;

    // Morphological reconstruction
    R=fast_reconstruct(J,I,conn);

    BW=(I-R)>0;

endfunction


function R=fast_reconstruct(marker,mask,conn)

    [rows,cols]=size(mask);

    R=marker;

    maxQ=rows*cols;

    Qx=zeros(maxQ,1);
    Qy=zeros(maxQ,1);

    head=1;
    tail=0;

    //----------------------------------
    // Initialize queue only on pixels
    // that may change
    //----------------------------------

    for i=2:rows-1
        for j=2:cols-1

            if R(i,j)<mask(i,j) then

                tail=tail+1;

                Qx(tail)=i;
                Qy(tail)=j;

            end

        end
    end

    //-----------------------------------
    // Connectivity offsets
    //-----------------------------------

    if conn==4 then

        dx=[-1 1 0 0];
        dy=[0 0 -1 1];

    else

        dx=[-1 -1 -1 0 0 1 1 1];
        dy=[-1 0 1 -1 1 -1 0 1];

    end

    n=size(dx,"*");

    //-------------------------------------
    // Queue propagation
    //-------------------------------------

    while head<=tail

        x=Qx(head);
        y=Qy(head);

        head=head+1;

        mx=R(x,y);

        for k=1:n

            xx=x+dx(k);
            yy=y+dy(k);

            if xx>=1 & xx<=rows & yy>=1 & yy<=cols then

                v=min(mask(xx,yy),mx);

                if v>R(xx,yy) then

                    R(xx,yy)=v;

                    tail=tail+1;

                    Qx(tail)=xx;
                    Qy(tail)=yy;

                end

            end

        end

    end

endfunction