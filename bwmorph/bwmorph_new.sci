function bw_out = bwmorph_thin_fast(bw, n)

    // If iteration count not given,
    // continue until image stabilizes
    if argn(2) < 2 then
        n = %inf;
    end

    // Convert input to binary
    bw_out = double(bw > 0);

    // Build lookup tables only once
    [lut1, lut2] = build_luts();

    [rows, cols] = size(bw_out);

    iter = 0;
    changed = %t;

    while changed

        // stop if maximum iterations reached
        if n <> %inf & iter >= n then
            break;
        end

        iter = iter + 1;
        changed = %f;

        //------------------------------------------------
        // PASS 1
        //------------------------------------------------

        del = zeros(rows, cols);

        // Process only interior pixels
        for r = 2:rows-1

            for c = 2:cols-1

                if bw_out(r,c)==1 then

                    //-------------------------------------
                    // Read neighborhood
                    //-------------------------------------

                    P2 = bw_out(r-1,c);
                    P3 = bw_out(r-1,c+1);
                    P4 = bw_out(r,c+1);

                    P5 = bw_out(r+1,c+1);
                    P6 = bw_out(r+1,c);
                    P7 = bw_out(r+1,c-1);

                    P8 = bw_out(r,c-1);
                    P9 = bw_out(r-1,c-1);

                    //-------------------------------------
                    // Convert neighborhood into code
                    //-------------------------------------

                    code = 0;

                    code = code + P2*1;
                    code = code + P3*2;
                    code = code + P4*4;
                    code = code + P5*8;

                    code = code + P6*16;
                    code = code + P7*32;
                    code = code + P8*64;
                    code = code + P9*128;

                    //-------------------------------------
                    // Lookup deletion condition
                    //-------------------------------------

                    if lut1(code+1)==1 then
                        del(r,c)=1;
                    end

                end

            end

        end

        //-----------------------------------------
        // Delete marked pixels
        //-----------------------------------------

        if or(del==1) then

            bw_out(del==1)=0;

            changed=%t;

        end


        //------------------------------------------------
        // PASS 2
        //------------------------------------------------

        del=zeros(rows,cols);

        for r=2:rows-1

            for c=2:cols-1

                if bw_out(r,c)==1 then

                    //--------------------------------
                    // Read neighbors
                    //--------------------------------

                    P2=bw_out(r-1,c);
                    P3=bw_out(r-1,c+1);
                    P4=bw_out(r,c+1);

                    P5=bw_out(r+1,c+1);
                    P6=bw_out(r+1,c);
                    P7=bw_out(r+1,c-1);

                    P8=bw_out(r,c-1);
                    P9=bw_out(r-1,c-1);

                    //--------------------------------
                    // Compute code
                    //--------------------------------

                    code=0;

                    code=code+P2*1;
                    code=code+P3*2;
                    code=code+P4*4;
                    code=code+P5*8;

                    code=code+P6*16;
                    code=code+P7*32;
                    code=code+P8*64;
                    code=code+P9*128;

                    //--------------------------------
                    // LUT test
                    //--------------------------------

                    if lut2(code+1)==1 then
                        del(r,c)=1;
                    end

                end

            end

        end

        //-----------------------------------------
        // delete pass2 pixels
        //-----------------------------------------

        if or(del==1) then

            bw_out(del==1)=0;

            changed=%t;

        end

    end

endfunction