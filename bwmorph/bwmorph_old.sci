function [A, B] = compute_AB(bw_out, r, c)
    P = [bw_out(r-1,c),   bw_out(r-1,c+1), ...
         bw_out(r,  c+1), bw_out(r+1,c+1), ...
         bw_out(r+1,c),   bw_out(r+1,c-1), ...
         bw_out(r,  c-1), bw_out(r-1,c-1)];
    B = sum(P);
    A = 0;
    for i = 1:7
        if P(i)==0 & P(i+1)==1 then A = A+1; end
    end
    if P(8)==0 & P(1)==1 then A = A+1; end
endfunction

function bw_out = bwmorph_thin_old(bw, n)
    if argn(2) < 3 then n = %inf; end

    bw_out = double(bw > 0);
    [rows, cols] = size(bw_out);

    iter    = 0;
    changed = %t;

    while changed
        if n ~= %inf & iter >= n then break; end
        iter    = iter + 1;
        changed = %f;

        del1 = zeros(rows, cols);
        for r = 2:rows-1
            for c = 2:cols-1
                if bw_out(r,c) == 1 then
                    [A, B] = compute_AB(bw_out, r, c);
                    P2 = bw_out(r-1,c); P4 = bw_out(r,c+1);
                    P6 = bw_out(r+1,c); P8 = bw_out(r,c-1);
                    if B>=2 & B<=6 & A==1 & (P2*P4*P6==0) & (P4*P6*P8==0) then
                        del1(r,c) = 1;
                    end
                end
            end
        end
        if or(del1==1) then
            bw_out(del1==1) = 0;
            changed = %t;
        end

        del2 = zeros(rows, cols);
        for r = 2:rows-1
            for c = 2:cols-1
                if bw_out(r,c) == 1 then
                    [A, B] = compute_AB(bw_out, r, c);
                    P2 = bw_out(r-1,c); P4 = bw_out(r,c+1);
                    P6 = bw_out(r+1,c); P8 = bw_out(r,c-1);
                    if B>=2 & B<=6 & A==1 & (P2*P6*P8==0) & (P2*P4*P8==0) then
                        del2(r,c) = 1;
                    end
                end
            end
        end
        if or(del2==1) then
            bw_out(del2==1) = 0;
            changed = %t;
        end

    end
endfunction

function out = bwmorph_old(bw, op, n)
    if argn(2) < 3 then n = %inf; end
    select op
    case 'thin'
        out = bwmorph_thin_old(bw, n);
    else
        error('bwmorph_old: unsupported operation ''%s''', op);
    end
endfunction
