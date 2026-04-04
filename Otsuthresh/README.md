# OTSUTHRESH Function

## Description
The otsuthresh function computes the optimal global threshold using Otsu’s method based on a given histogram. It replicates the behavior of the otsuthresh function from Octave’s image package.

Otsu’s method determines a threshold that separates data into two classes (background and foreground) by maximizing the variance between these classes.

---

## Syntax
thresh = otsuthresh(hist_counts)

---

## Parameters

hist_counts
A one-dimensional vector containing histogram counts. Each element represents the number of pixels corresponding to a specific intensity level. Typically, the histogram has 256 bins for an 8-bit grayscale image.

---

## Output

thresh
A scalar value in the range [0, 1] representing the normalized threshold. To obtain the actual intensity threshold, multiply by (number of bins - 1).


---

## Algorithm

Step 1: Input validation
- Ensure exactly one input argument is provided
- Ensure histogram values are non-negative
- Ensure histogram is not empty

Step 2: Normalize histogram
- Convert counts into probabilities:
  p(i) = hist_counts(i) / total number of pixels

Step 3: Compute cumulative quantities
- omega(k): cumulative probability up to bin k
- mu(k): cumulative mean up to bin k
- mu_t: total mean of the histogram

Step 4: Compute between-class variance for each threshold k
- Divide data into two classes:
  Class 0: [0 to k]
  Class 1: [k+1 to end]

- Compute:
  w0 = omega(k)
  w1 = 1 - w0

  mu0 = mu(k) / w0
  mu1 = (mu_t - mu(k)) / w1

- Between-class variance:
  sigma_b^2 = w0 * w1 * (mu0 - mu1)^2

Step 5: Find optimal threshold
- Select the index k that maximizes sigma_b^2

Step 6: Normalize threshold
- thresh = (k - 1) / (N - 1)

---

## Approach

The implementation follows a structured and efficient approach:

1. Histogram-based processing
   - Works directly on histogram instead of raw image
   - Reduces computational complexity

2. Cumulative computations
   - Uses cumulative sums for probabilities and means
   - Avoids recomputation inside loops

3. Iterative optimization
   - Evaluates all possible thresholds
   - Selects the one maximizing between-class variance

4. Numerical safety
   - Handles edge cases where class probabilities become zero

---

## Test Cases

1. Bimodal Gaussian histogram
Expected: threshold near midpoint between peaks

2. Uniform histogram
Expected: threshold near 0.5

3. Single intensity at low value
Expected: threshold near 0

4. Single intensity at high value
Expected: threshold near boundary

5. Synthetic binary image histogram
Expected: correct separation of two intensity groups

---

## Conclusion

The otsuthresh function accurately computes the optimal threshold using Otsu’s method. It efficiently utilizes histogram-based computations and cumulative statistics to achieve reliable and consistent results.