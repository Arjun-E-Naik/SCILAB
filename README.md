# Scilab Image Processing Toolbox (SCI Functions)

## Overview
This project implements essential image processing functions in Scilab using `.sci` files, similar to the functionality provided in Octave’s image package.

All functions are modular, reusable, and designed for efficient numerical computation.

---

## Implemented Functions

### 1. immse.sci
Computes the Mean Squared Error (MSE) between two images or numerical arrays.

- Input: Two matrices of same size
- Output: Scalar value (error)
- Purpose: Measures similarity between two images
- Formula:
  MSE = mean((A - B)^2)

---

### 2. otsuthresh.sci
Computes the optimal global threshold using Otsu’s method from histogram data.

- Input: Histogram counts (1D vector)
- Output: Normalized threshold value (range: 0 to 1)
- Purpose: Used for image segmentation (binarization)
- Key Concept:
  Maximizes between-class variance to separate foreground and background

---

### 3. imgradientxy.sci
Computes directional gradients (Gx and Gy) of a grayscale image using various methods.

- Input: 2-D grayscale image matrix, optional method string
- Output: Two matrices (Gx, Gy) of same size as input
- Purpose: Edge detection and gradient computation
- Methods: 'sobel' (default), 'prewitt', 'central', 'intermediate'
- Key Concept:
  Gx > 0: intensity increases left to right
  Gy > 0: intensity increases top to bottom

---

## File Structure

- immse.sci          → Mean Squared Error function
- otsuthresh.sci     → Otsu threshold computation
- imgradientxy.sci   → Directional gradient computation
- test scripts       → Contain validation and test cases

---

## How to Run

### Prerequisites
```bash
sudo apt-get install -y scilab scilab-cli
```

### Run Individual Functions
```bash
# Run immse function
scilab-cli -nb -f immse/immse.sci

# Run otsuthresh function
scilab-cli -nb -f Otsuthresh/Otsuthresh.sci

# Run imgradientxy function
scilab-cli -nb -f Imgradientxy/Imgradientxy.sci
```

### Run Individual Tests
```bash
# Test immse function
scilab-cli -nb -f tests/test_immse.sci

# Test otsuthresh function
scilab-cli -nb -f tests/test_otsuthresh.sci

# Test imgradientxy function
scilab-cli -nb -f tests/test_imgradientxy.sci
```

### Run All Tests Together
```bash
# Run complete test suite
bash tests/run_all_tests.sh

# Run specific test only
bash tests/run_all_tests.sh immse
bash tests/run_all_tests.sh otsuthresh
bash tests/run_all_tests.sh imgradientxy
```

## How to Use

1. Open Scilab
2. Load function file:
   exec('immse.sci', -1)
   exec('otsuthresh.sci', -1)

3. Call function:
   err = immse(A, B)
   thresh = otsuthresh(hist_counts)

---

## Approach

- Functions implemented using vectorized operations
- Histogram-based processing for efficiency
- Cumulative sums used to reduce computation time
- Designed to match behavior of Octave image package

---

## Optimization Techniques

- Vectorization instead of loops
- Preallocation of arrays
- Reduced redundant calculations
- Efficient use of built-in functions (mean, sum, cumsum)

---

## Test Coverage

Each function includes test cases covering:

- Basic functionality
- Edge cases (empty, uniform data, extreme values)
- Realistic image scenarios

---

## GitHub Repository



https://github.com/Arjun-E-Naik/SCILAB

---

