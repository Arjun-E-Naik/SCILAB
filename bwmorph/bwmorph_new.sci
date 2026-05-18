function [A, B] = AB_from_bits(P)
    B = sum(P);
    A = 0;
    for i = 1:7
        if P(i)==0 & P(i+1)==1 then A = A+1; end
    end
    if P(8)==0 & P(1)==1 then A = A+1; end
endfunction

function [lut1, lut2] = build_luts()
    lut1 = zeros(1, 256);
    lut2 = zeros(1, 256);

    for code = 0:255
        P  = double(bitget(uint8(code), 1:8));
        [A, B] = AB_from_bits(P);

        P2 = P(1);
        P4 = P(3);
        P6 = P(5);
        P8 = P(7);

        if B>=2 & B<=6 & A==1 then
            if (P2*P4*P6 == 0) & (P4*P6*P8 == 0) then
                lut1(code+1) = 1;
            end
            if (P2*P6*P8 == 0) & (P2*P4*P8 == 0) then
                lut2(code+1) = 1;
            end
        end
    end
endfunction

function code = compute_neigh_code(img, r, c)
    P = [img(r-1,c  ), img(r-1,c+1), img(r,  c+1), img(r+1,c+1), ...
         img(r+1,c  ), img(r+1,c-1), img(r,  c-1), img(r-1,c-1)];
    code = 0;
    for i = 1:8
        code = code + P(i) * 2^(i-1);
    end
    code = int(code);
endfunction

function out = median_filter3(img)
    out = img;
    [m, n] = size(img);
    for r = 2:m-1
        for c = 2:n-1
            w = matrix(img(r-1:r+1, c-1:c+1), 1, -1);
            out(r,c) = gsort(w, 'g', 'i')(5);
        end
    end
endfunction

function bw_out = bwmorph_thin_new(bw, n)
    if argn(2) < 3 then n = %inf; end

    bw_out = double(bw > 0);
    [rows, cols] = size(bw_out);

    [lut1, lut2] = build_luts();

    iter    = 0;
    changed = %t;

    while changed
        if n ~= %inf & iter >= n then break; end
        iter    = iter + 1;
        changed = %f;

        del = zeros(rows, cols);
        for r = 2:rows-1
            for c = 2:cols-1
                if bw_out(r,c) == 1 then
                    code = compute_neigh_code(bw_out, r, c);
                    if lut1(code+1) == 1 then del(r,c) = 1; end
                end
            end
        end
        if or(del == 1) then
            bw_out(del == 1) = 0;
            changed = %t;
        end

        del = zeros(rows, cols);
        for r = 2:rows-1
            for c = 2:cols-1
                if bw_out(r,c) == 1 then
                    code = compute_neigh_code(bw_out, r, c);
                    if lut2(code+1) == 1 then del(r,c) = 1; end
                end
            end
        end
        if or(del == 1) then
            bw_out(del == 1) = 0;
            changed = %t;
        end

    end
endfunction

function out = bwmorph_new(bw, op, n)
    if argn(2) < 3 then n = %inf; end

    select op
    case 'thin'
        out = bwmorph_thin_new(bw, n);
    case 'skel'
        out = bwmorph_thin_new(bw, %inf);
    case 'denoise'
        out = median_filter3(double(bw > 0));
    else
        error('bwmorph_new: unsupported operation ''%s''.  Supported: thin, skel, denoise', op);
    end
endfunction
