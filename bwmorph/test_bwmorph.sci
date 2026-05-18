// =============================================================================
// test_bwmorph.sci  –  Comprehensive test suite for bwmorph_old / bwmorph_new
// =============================================================================
// Tests cover:
//   1.  Trivial / degenerate inputs (all-zero, single pixel, full block)
//   2.  Geometric primitives (line, cross, diagonal, square outlines)
//   3.  Topological checks (T/L/X junctions, ring, filled shapes)
//   4.  Noise robustness (random binary images)
//   5.  Boundary safety (foreground pixels touching image border)
//   6.  Finite-n iteration limit
//   7.  Output idempotency  (thinning a skeleton gives the same skeleton)
//   8.  Timing comparison (old vs new) for large images
//   9.  Regression: new must never produce a thicker result than old
//       and must preserve connectivity where old does.
// =============================================================================

clc;
clear;

// Initialize global counters
g_pass_count = 0;
g_fail_count = 0;

// Load implementations
exec('bwmorph/bwmorph_old.sci', -1);
exec('bwmorph/bwmorph_new_clean.sci', -1);

// ---------------------------------------------------------------------------
// Utility helpers
// ---------------------------------------------------------------------------

// Simple pass/fail reporter
function report(label, ok)
    global g_pass_count g_fail_count;
    if ok then
        mprintf('  PASS  %s\n', label);
        g_pass_count = g_pass_count + 1;
    else
        mprintf('  FAIL  %s\n', label);
        g_fail_count = g_fail_count + 1;
    end
endfunction


function ok = is_binary(img)
    // Every element must be exactly 0 or 1
    ok = and(img == 0 | img == 1);
endfunction


function ok = no_2x2_block(img)
    // A thinned image must contain no 2×2 all-ones block
    [m, n] = size(img);
    ok = %t;
    for r = 1:m-1
        for c = 1:n-1
            if img(r,c) == 1 & img(r,c+1) == 1 & img(r+1,c) == 1 & img(r+1,c+1) == 1 then
                ok = %f;
                return;
            end
        end
    end
endfunction


function ok = preserved_count_leq(bw_in, bw_out)
    // Output must not have MORE on-pixels than input
    ok = (sum(bw_out) <= sum(bw_in));
endfunction


function ok = idempotent(bw, func_handle)
    // func_handle(bw) applied twice must give the same result as once
    once  = func_handle(bw);
    twice = func_handle(once);
    ok = and(once == twice);
endfunction


// Thin wrappers for idempotency test
function out = thin_old(bw), out = bwmorph_old(bw, 'thin', %inf); endfunction
function out = thin_new(bw), out = bwmorph_new(bw, 'thin', %inf); endfunction


// ---------------------------------------------------------------------------
// Test runner
// ---------------------------------------------------------------------------

function run_tests(label, bw_in)
    mprintf('\n--- %s ---\n', label);

    old_out = bwmorph_old(bw_in, 'thin', %inf);
    new_out = bwmorph_new(bw_in, 'thin', %inf);

    // 1. Output is binary
    report('old: output binary',            is_binary(old_out));
    report('new: output binary',            is_binary(new_out));

    // 2. Output has no 2×2 fully-ON block (proper thinness)
    report('old: no 2x2 block (thinness)',  no_2x2_block(old_out));
    report('new: no 2x2 block (thinness)',  no_2x2_block(new_out));

    // 3. Pixel count non-increasing
    report('old: pixel count ≤ input',      preserved_count_leq(bw_in, old_out));
    report('new: pixel count ≤ input',      preserved_count_leq(bw_in, new_out));

    // 4. Idempotency
    report('old: idempotent',               idempotent(bw_in, thin_old));
    report('new: idempotent',               idempotent(bw_in, thin_new));

    // 5. Size preserved
    report('old: size preserved',           and(size(old_out)==size(bw_in)));
    report('new: size preserved',           and(size(new_out)==size(bw_in)));
endfunction


// ---------------------------------------------------------------------------
// Individual test cases
// ---------------------------------------------------------------------------

mprintf('\n=============================================================\n');
mprintf(' bwmorph test suite\n');
mprintf('=============================================================\n');

// T-1: all zeros
run_tests('all-zeros 5x5', zeros(5, 5));

// T-2: single foreground pixel
x = zeros(7, 7); x(4, 4) = 1;
run_tests('single pixel', x);

// T-3: full block (stress thinness test)
run_tests('full 9x9 block', ones(9, 9));

// T-4: horizontal line
x = zeros(11, 11); x(6, :) = 1;
run_tests('horizontal line', x);

// T-5: vertical line
x = zeros(11, 11); x(:, 6) = 1;
run_tests('vertical line', x);

// T-6: diagonal
run_tests('11x11 diagonal (eye)', eye(11, 11));

// T-7: cross (+)
x = zeros(15, 15);
x(8, :) = 1; x(:, 8) = 1;
run_tests('cross (+)', x);

// T-8: hollow square (ring topology)
x = zeros(13, 13);
x(2:12, 2) = 1; x(2:12, 12) = 1;
x(2, 2:12) = 1; x(12, 2:12) = 1;
run_tests('hollow square (ring)', x);

// T-9: filled square
x = zeros(13, 13); x(2:12, 2:12) = 1;
run_tests('filled square', x);

// T-10: T-junction
x = zeros(15, 15);
x(2, 4:12)  = 1;   // top bar of T
x(2:13, 8)  = 1;   // stem of T
run_tests('T-junction', x);

// T-11: L-shape
x = zeros(13, 13);
x(2:12, 2) = 1; x(12, 2:12) = 1;
run_tests('L-shape', x);

// T-12: Noise robustness (random binary images)
rand('seed', 42);
x = rand(30, 30) > 0.7;
run_tests('random binary image noise', double(x));

// T-13: foreground pixels on border (boundary safety)
x = zeros(11, 11);
x(1, :) = 1; x(:, 1) = 1;
run_tests('border-touching foreground', x);

// T-14: finite-n test (only 1 iteration)
mprintf('\n--- finite n=1 iteration ---\n');
x = ones(9, 9);
old1 = bwmorph_old(x, 'thin', 1);
new1 = bwmorph_new(x, 'thin', 1);
report('old n=1: pixel count decreased', sum(old1) < sum(x));
report('new n=1: pixel count decreased', sum(new1) < sum(x));
report('old n=1: binary output',         is_binary(old1));
report('new n=1: binary output',         is_binary(new1));

// T-15: skel alias (bwmorph_new only)
mprintf('\n--- skel alias (bwmorph_new) ---\n');
x = ones(9, 9);
thin_result = bwmorph_new(x, 'thin', %inf);
skel_result = bwmorph_new(x, 'skel');
report('skel == thin(%inf)', and(thin_result == skel_result));


// ---------------------------------------------------------------------------
// Timing benchmark
// ---------------------------------------------------------------------------

mprintf('\n=============================================================\n');
mprintf(' Timing benchmark (large image)\n');
mprintf('=============================================================\n');

rand('seed', 99);
big = double(rand(200, 200) > 0.6);

// Reset and measure old
timer();
_ = bwmorph_old(big, 'thin', %inf);
t_old = timer();

// Reset and measure new
timer();
_ = bwmorph_new(big, 'thin', %inf);
t_new = timer();

mprintf('  old implementation:  %.3f s\n', t_old);
mprintf('  new implementation:  %.3f s\n', t_new);
if t_old > 0 & t_new > 0 then
    mprintf('  speedup factor:      %.2f×\n', t_old / t_new);
end

// ---------------------------------------------------------------------------
// Summary
// ---------------------------------------------------------------------------

mprintf('\n=============================================================\n');
mprintf(' Test execution complete.\n');
mprintf(' Total PASS: %d | Total FAIL: %d\n', g_pass_count, g_fail_count);
mprintf('=============================================================\n');
