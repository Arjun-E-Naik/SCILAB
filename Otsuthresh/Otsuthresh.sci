
function thresh = otsuthresh(hist_counts)
    if argn(2) ~= 1 then
        error("otsuthresh: exactly one input argument (histogram) required.");
    end

    hist_counts = double(hist_counts(:));

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
