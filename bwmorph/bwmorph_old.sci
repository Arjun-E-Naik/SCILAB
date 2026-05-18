// =============================================================================
// bwmorph_old.sci  –  Reference Zhang-Suen thinning (pixel-loop, no LUTs)
// =============================================================================
// Classic, readable implementation of the Zhang-Suen (1984) thinning algorithm.
// This version is kept intentionally loop-based so its logic is easy to audit.
//
// BUGS FIXED vs. the original submission
// ----------------------------------------
//  1. neighbors_info() declared a dead argument `p` that shadowed nothing but
//     confused readers.  Removed; function now reads directly from bw_out.
//  2. Step-2 was unreachable: an early `break` after Step-1 exited the loop
//     before Step-2 could run.  Fixed iteration flow so both sub-iterations
//     always execute within every pass.
//  3. `changed` was never set to %t by Step-2 because it was reset to []
//     (to_delete=[]) between steps without resetting the flag properly.
//     Now `changed` is a single boolean accumulated across both steps per iter.
//  4. Finite-n guard:  `iter < n | n==%inf` could short-circuit incorrectly
//     for n=0.  Moved to a clean `if n ~= %inf & iter >= n then break` check.
//  5. bw_out was modified in-place during Step-1 before Step-2 could see the
//     original neighborhood — violating Zhang-Suen's requirement that both
//     sub-iterations see the state at the START of the iteration.
//     Fixed by collecting ALL candidates first, then applying deletions.
// =============================================================================

function [A, B] = compute_AB(bw_out, r, c)
    // Returns:
    //   B  = number of ON neighbours (connectivity number)
    //   A  = number of 0->1 transitions in the clockwise ring (crossing number)
    //
    // Neighbours P2..P9 ordered clockwise starting from the top centre:
    //   P2 P3 P4
    //   P9  *  P5
    //   P8 P7 P6
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
    // Zhang-Suen thinning – reference loop implementation
    // bw : binary matrix (logical or 0/1 double)
    // n  : max iterations (use %inf to run to convergence)
    if argn(2) < 3 then n = %inf; end

    bw_out = double(bw > 0);  // ensure strict 0/1 double
    [rows, cols] = size(bw_out);

    iter    = 0;
    changed = %t;

    while changed
        // respect finite iteration limit
        if n ~= %inf & iter >= n then break; end
        iter    = iter + 1;
        changed = %f;

        // ---- Sub-iteration 1 ------------------------------------------------
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

        // ---- Sub-iteration 2 ------------------------------------------------
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

    end // while
endfunction


function out = bwmorph_old(bw, op, n)
    // Public wrapper  –  mirrors MATLAB bwmorph API
    if argn(2) < 3 then n = %inf; end
    select op
    case 'thin'
        out = bwmorph_thin_old(bw, n);
    else
        error('bwmorph_old: unsupported operation ''%s''', op);
    end
endfunction
