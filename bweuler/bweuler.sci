function eul = bweuler_fast(BW, conn)

    // Default connectivity
    if argn(2)<2 then
        conn=8;
    end

    if conn<>4 & conn<>8 then
        error("Connectivity must be 4 or 8");
    end

    // Binary conversion
    BW = BW<>0;

    // Pad with zeros
    [r,c]=size(BW);

    P=zeros(r+1,c+1);

    P(2:$,2:$)=BW;

    // Extract all 2×2 blocks
    b1=P(1:$-1,1:$-1);
    b2=P(1:$-1,2:$);
    b3=P(2:$,1:$-1);
    b4=P(2:$,2:$);

    // Encode:
    // b1 +2b2 +4b3 +8b4

    code=b1 +2*b2 +4*b3 +8*b4;

    //--------------------------------------------------
    // LUT from digital topology
    //--------------------------------------------------

    if conn==8 then

        // 8-connected foreground
        LUT=[0 ...
             1 1 0 ...
             1 0 2 -1 ...
             1 2 0 -1 ...
             0 -1 -1 0];

    else

        // 4-connected foreground
        LUT=[0 ...
             1 1 0 ...
             1 0 -2 -1 ...
             1 -2 0 -1 ...
             0 -1 -1 0];

    end

    //---------------------------------------------------
    // LUT indexing
    //---------------------------------------------------

    vals=LUT(code+1);

    eul=sum(vals)/4;

endfunction