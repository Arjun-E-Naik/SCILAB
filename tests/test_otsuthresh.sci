
// test_otsuthresh.sce — Standalone test runner for otsuthresh
// Run: scilab-cli -nb -f tests/test_otsuthresh.sce


function thresh = otsuthresh(hist_counts)
    if argn(2) ~= 1 then
        error("otsuthresh: exactly one input argument required.");
    end
    hist_counts = double(hist_counts(:));
    if min(hist_counts) < 0 then
        error("otsuthresh: histogram counts must be non-negative.");
    end
    N = length(hist_counts);
    total = sum(hist_counts);
    if total == 0 then
        error("otsuthresh: histogram is empty.");
    end
    p     = hist_counts / total;
    omega = cumsum(p);
    mu_t  = sum((0:N-1)' .* p);
    mu_k  = cumsum((0:N-1)' .* p);
    sigma_b_sq = zeros(N, 1);
    for k = 1:N
        w0 = omega(k); w1 = 1 - w0;
        if w0 > 0 & w1 > 0 then
            mu0 = mu_k(k) / w0;
            mu1 = (mu_t - mu_k(k)) / w1;
            sigma_b_sq(k) = w0 * w1 * (mu0 - mu1)^2;
        end
    end
    [mv, idx] = max(sigma_b_sq);
    thresh = (idx - 1) / (N - 1);
endfunction

passed = 0;
failed = 0;

function [p,f] = check(label, got, expected, tol, p, f)
    if abs(got - expected) <= tol then
        printf("   PASS  %s : %.6f\n", label, got);
        p = p + 1;
    else
        printf("  ✗ FAIL  %s : got=%.6f  expected=%.6f\n", label, got, expected);
        f = f + 1;
    end
endfunction



disp("  TESTS: otsuthresh");



// Test 1: Gaussian bimodal peaks → threshold near 0.49
h1 = zeros(256,1);
for k = 1:256
    h1(k) = 3000*exp(-((k-51)^2)/(2*15^2)) + 3000*exp(-((k-201)^2)/(2*15^2));
end
[passed,failed] = check("gaussian bimodal @50,200", otsuthresh(h1), 0.4902, 0.01, passed, failed);

// Test 2: Uniform histogram → ~0.498
[passed,failed] = check("uniform histogram", otsuthresh(ones(256, 1)*100), 0.498,  0.01, passed, failed);

// Test 3: Single spike at 0
h3 = zeros(256,1); h3(1) = 500;
[passed,failed] = check("single spike at gray=0", otsuthresh(h3), 0.0, 1e-10, passed, failed);

// Test 4: Two equal spikes verify output in range [0,1]
h4 = zeros(256,1); h4(100) = 1000; h4(200) = 1000;
T4 = otsuthresh(h4);
if T4 >= 0 & T4 <= 1 then
    printf("   PASS  two-spike output in [0,1] : %.6f\n", T4);
    passed = passed + 1;
else
    printf("   FAIL  two-spike output out of [0,1] : %.6f\n", T4);
    failed = failed + 1;
end

// Test 5: Synthetic binarization (left=50, right=200)
// Threshold lands at gray=50, use strict > so left pixels (==50) stay 0
I5 = [50*ones(10,5), 200*ones(10,5)];
c5 = zeros(256,1);
for v = matrix(I5,1,-1), c5(v+1) = c5(v+1)+1; end
T5 = otsuthresh(c5);
BW5 = (I5 > T5*255);
left_sum  = sum(sum(BW5(:,1:5)));
right_sum = sum(sum(BW5(:,6:10)));
[passed,failed] = check("binarize left-half = 0", double(left_sum), 0, 1e-10, passed, failed);
[passed,failed] = check("binarize right-half = 50", double(right_sum), 50, 1e-10, passed, failed);

// Test 6: Result always in [0,1]
rand("seed", 7);
h6 = floor(rand(256,1)*1000);
T6 = otsuthresh(h6);
if T6 >= 0 & T6 <= 1 then
    printf("   PASS  random histogram in [0,1] : %.6f\n", T6);
    passed = passed + 1;
else
    printf("   FAIL  random histogram out of range : %.6f\n", T6);
    failed = failed + 1;
end


printf("  Results: %d passed, %d failed\n", passed, failed);


if failed > 0 then
    exit(1);
else
    exit(0);
end
