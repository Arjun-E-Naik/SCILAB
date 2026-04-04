# IMGRADIENTXY Function

## Description
The imgradientxy function computes the directional gradients of a grayscale image along the horizontal (x) and vertical (y) directions. It replicates the behavior of the imgradientxy function from Octave’s image package.

The function supports multiple methods including Sobel, Prewitt, central differences, and forward (intermediate) differences.

---

## Syntax
[Gx, Gy] = imgradientxy(I)
[Gx, Gy] = imgradientxy(I, method)

---

## Parameters

I
Input image matrix (2-D grayscale image). The input must be a numeric matrix.

method (optional)
Specifies the gradient computation method. Default is 'sobel'.

Supported methods:
- 'sobel'        : Uses Sobel operator
- 'prewitt'      : Uses Prewitt operator
- 'central'      : Uses central difference approximation
- 'intermediate' : Uses forward difference approximation

---

## Output

Gx
Gradient of the image in the horizontal direction.

Gy
Gradient of the image in the vertical direction.

Both outputs are matrices of the same size as the input image.

---

## Algorithm

The function computes gradients using different approaches based on the selected method.

### 1. Sobel and Prewitt Methods (Convolution-based)

Step 1: Define convolution kernels
- Sobel uses weighted kernels to emphasize edges
- Prewitt uses uniform kernels

Step 2: Apply replicate padding to the image
- Border pixels are extended to avoid size reduction

Step 3: Slide a 3x3 window over the image

Step 4: For each pixel:
- Multiply the local 3x3 region with the kernel
- Sum all values to compute gradient

Step 5: Store results in Gx and Gy

---

### 2. Central Difference Method

Step 1: For each pixel, consider left and right neighbors

Step 2: Compute horizontal gradient:
Gx = (Right pixel - Left pixel) / distance

Step 3: Compute vertical gradient:
Gy = (Bottom pixel - Top pixel) / distance

Step 4: Handle borders using nearest valid pixel

---

### 3. Intermediate (Forward Difference) Method

Step 1: For each pixel:
- Compare with next pixel in x direction
- Compare with next pixel in y direction

Step 2: Compute:
Gx = Next column pixel - Current pixel
Gy = Next row pixel - Current pixel

Step 3: Handle borders using nearest valid pixel

---

## Approach

The implementation follows a hybrid approach:

1. For convolution-based methods (Sobel and Prewitt):
   - Explicit kernel definition is used
   - Manual convolution is implemented using loops
   - Replicate padding ensures correct boundary handling

2. For difference-based methods:
   - Direct pixel comparisons are used
   - Boundary conditions are handled using min and max indexing

This approach ensures clarity of implementation while maintaining correctness.

---

## Test Cases

1. Constant image
Expected: Gx = 0, Gy = 0

2. Vertical edge image
Expected: Gx large, Gy near zero

3. Horizontal edge image
Expected: Gy large, Gx near zero

4. Linear intensity ramp
Expected: uniform gradient in one direction

5. Small matrix validation
Expected: correct numerical gradients

---

## Conclusion

The function successfully computes directional gradients using multiple methods. It balances clarity and correctness while allowing scope for performance optimization using vectorized operations.