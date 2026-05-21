# STDFILT for Scilab

## Overview

STDFILT computes local standard deviation values in an image.

For each pixel:

1. Take neighborhood around pixel
2. Compute neighborhood standard deviation
3. Store result at corresponding pixel

Output highlights texture and local intensity variation.

Smooth regions:

small values

Edges / texture:

large values

Equivalent to MATLAB stdfilt.

---

# Syntax

J = stdfilt(I)

J = stdfilt(I,nhood)

Input:

I
    grayscale image

nhood
    neighborhood mask

default:

ones(3,3)

Output:

J

local standard deviation image

---

# Mathematical formulation

For neighborhood:

x1,x2,x3,...xN

mean:

μ=(1/N) summation{xi}

standard deviation:

σ=sqrt(
summatiion{(xi−μ)^2 /(N−1)
)}

Direct implementation requires many operations.

Instead we use:

Variance identity:

σ^2=E[X^2]−E[X]^2

Expanding:

σ^2=
(
summation{x^2}−(summation{x^2}/N
)/(N−1)

This avoids repeatedly computing means.

---

# Algorithm

Step 1

Convert image to double

to avoid overflow

---

Step 2

Compute padding size

Example:

3×3 neighborhood

requires:

1 row top
1 row bottom
1 column left
1 column right

---

Step 3

Symmetric padding

Example:

Original:

1 2 3

Padding:

2 1 2 3 2

This preserves boundaries.

---

Step 4

Compute:

S1=local sum

Using:

conv2()

S2=local squared sum

conv2(I^2)

---

Step 5

Compute variance

V=(S2−S1^2/N)/(N−1)

---

Step 6

Compute standard deviation

J=sqrt(V)

---

# Complexity

Image size:

M×N

Neighborhood:

K×L

Convolution complexity:

O(MNKL)

No explicit nested loops used.

Vectorization gives significant speedup.

---

# Optimization techniques used

- Vectorized implementation

- Symmetric padding

- Removed neighborhood extraction loops

- Multiplication instead of power

---

# Example

I=imread('cameraman.tif');

J=stdfilt(I);

imshow(J,[])

Result:

Edges and textured regions become bright.

Flat regions remain dark.

---

# Applications

Texture segmentation

Edge enhancement

Feature extraction

Medical image analysis

Defect detection



---

