
// otsuthresh.sce — Otsu's Global Threshold from Histogram
// Equivalent to Octave image package: otsuthresh()


function thresh = otsuthresh(hist_counts)
// otsuthresh - Compute Otsu's optimal global threshold from a histogram
//
// Calling Sequence:
//   thresh = otsuthresh(hist_counts)
//
// Parameters:
//   hist_counts : 1-D non-negative vector of histogram bin counts.
//                 Typically 256 elements for an 8-bit grayscale image.
//   thresh      : Scalar double in [0, 1] — normalized threshold value.
//                 Multiply by (num_bins - 1) to get the actual gray level.
//                 Use as:  BW = I >= thresh * 255
//
// Description:
//   Maximizes the inter-class variance between background and foreground:
//     σ²_B(k) = ω₀(k) · ω₁(k) · [μ₀(k) − μ₁(k)]²
//   where ω are class probabilities and μ are class means.
//   Result is normalised to [0,1] matching Octave's otsuthresh output.

    if argn(2) ~= 1 then
        error("otsuthresh: exactly one input argument (histogram) required.");
    end

    hist_counts = double(hist_counts(:));   // column vector, double

    if min(hist_counts) < 0 then
        error("otsuthresh: histogram counts must be non-negative.");
    end

    N     = length(hist_counts);
    total = sum(hist_counts);

    if total == 0 then
        error("otsuthresh: histogram is empty (all zeros).");
    end

    p     = hist_counts / total;           
    omega = cumsum(p);                     
    mu_t  = sum((0:N-1)' .* p);           
    mu_k  = cumsum((0:N-1)' .* p);       

    sigma_b_sq = zeros(N, 1);
    for k = 1:N
        w0 = omega(k);
        w1 = 1 - w0;
        if w0 > 0 & w1 > 0 then
            mu0 = mu_k(k) / w0;
            mu1 = (mu_t - mu_k(k)) / w1;
            sigma_b_sq(k) = w0 * w1 * (mu0 - mu1)^2;
        end
    end

    [mv, idx] = max(sigma_b_sq);
    thresh   = (idx - 1) / (N - 1);

endfunction


// TEST CASES



disp("  otsuthresh — Test Cases");


// Test 1: Gaussian bimodal peaks at gray=50 and gray=200
// Threshold expected near gray=125 (normalised ~0.49)
h1 = zeros(256,1);
for k = 1:256
    h1(k) = 3000*exp(-((k-51)^2)/(2*15^2)) + 3000*exp(-((k-201)^2)/(2*15^2));
end
T1 = otsuthresh(h1);
printf("Test 1 [Gaussian bimodal @50,200] : thresh=%.4f  gray=%d  (expected ~0.4902, ~125)\n", T1, round(T1*255));

// Test 2: Uniform histogram -> threshold near 0.5
h2 = ones(256,1) * 100;
T2 = otsuthresh(h2);
printf("Test 2 [Uniform histogram]        : thresh=%.4f         (expected ~0.4980)\n", T2);

// Test 3: Single spike at gray=0 -> threshold = 0
h3 = zeros(256,1); h3(1) = 1000;
T3 = otsuthresh(h3);
printf("Test 3 [All pixels gray=0]        : thresh=%.4f         (expected 0.0000)\n", T3);

// Test 4: Single spike at gray=255 -> threshold = 1 (or nearest)
h4 = zeros(256,1); h4(256) = 1000;
T4 = otsuthresh(h4);
printf("Test 4 [All pixels gray=255]      : thresh=%.4f         (expected 0.0000 — single class)\n", T4);

// Test 5: Synthetic binarization (left half=40, right half=200)
I5 = [40*ones(10,5), 200*ones(10,5)];
counts5 = zeros(256,1);
for v = matrix(I5, 1, -1)
    counts5(v+1) = counts5(v+1) + 1;
end
T5 = otsuthresh(counts5);
BW5 = (I5 >= T5 * 255);
printf("Test 5 [Synthetic image binarize] : thresh=%.4f\n", T5);
printf("BW left-half  sum = %d  (expected 0)\n",  sum(sum(BW5(:,1:5))));
printf(" BW right-half sum = %d  (expected 50)\n", sum(sum(BW5(:,6:10))));



quit
