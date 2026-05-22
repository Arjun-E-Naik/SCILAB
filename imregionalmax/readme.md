
# immaximas — Optimized Regional Maxima Detection for Scilab

 **Regional Maxima Detection** (`immaximas`) is using **queue-based grayscale morphological reconstruction**.

This implementation improves upon conventional iterative approaches by replacing repeated image scans with a **linear-time propagation strategy**, reducing computation time and avoiding unnecessary memory reallocations.

---

## Overview

Regional maxima are connected sets of pixels with constant intensity values where every neighboring pixel outside the region has a lower intensity.

The function returns a binary image indicating locations of regional maxima.

Equivalent MATLAB function:

```matlab
BW = imregionalmax(I)
````

Scilab implementation:

```scilab
BW = immaximas(I)
BW = immaximas(I,conn)
```

where:

* `I` → grayscale image
* `conn` → connectivity (`4` or `8`)
* `BW` → binary mask of regional maxima

---

# Example

Input:

```text
1 1 1
1 9 1
1 1 1
```

Output:

```text
0 0 0
0 1 0
0 0 0
```

---

# Mathematical Definition

Let an image be defined as:

$$I: \Omega \rightarrow \mathbb{R}$$

where $\Omega$ is the image domain.

A connected component $C$ is a regional maximum if it satisfies two conditions:

### Condition 1
All pixels inside the region have equal intensity:

$$I(p) = k \quad \forall \quad p \in C$$

---

### Condition 2
All neighboring pixels outside the region satisfy:

$$I(q) < k \quad \forall \quad q \in N(C)$$

where $N(C)$ represents the neighboring pixels of $C$.

---

# Morphological Reconstruction Formulation

Regional maxima can be computed through grayscale reconstruction:

1. **Create marker image:**
   $$J = I - 1$$

2. **Perform geodesic reconstruction:**
   $$R = \text{Rec}(J, I)$$

3. **Extract regional maxima:**
   $$BW = (I - R) > 0$$

This formulation avoids explicit plateau searching.
---

# Why Morphological Reconstruction?

Naive approaches:

* compare every pixel
* repeatedly scan image
* iterate until no changes occur

Typical complexity:

```
O(kN)


where:

* N = number of pixels
* k = iterations to convergence
```


runtime increases significantly.

Instead, grayscale reconstruction propagates information only where changes occur.

---

# Core Idea

Rather than repeatedly processing the entire image:

Use:

```text
Queue propagation
```

Only pixels that may change are visited.

This converts iterative scans into localized updates.

---

# Algorithm

## Step 1

Convert image:

```scilab
I=double(I)
```

This ensures consistent arithmetic behavior.

---

## Step 2

Create marker image:

```scilab
J=I-1
```

The marker image is slightly lower than original image.

---

## Step 3

Initialize reconstruction:

```scilab
R=J
```

---

## Step 4

Insert candidate pixels into queue:

```scilab
if R(i,j)<mask(i,j)
```

Only pixels capable of changing are processed.

---

## Step 5

Perform queue propagation

For each pixel:

Visit neighbors:

For 4-connectivity:

```text
up
down
left
right
```

For 8-connectivity:

```text
up
down
left
right
diagonals
```

Update:

```
v=min(mask(x,y),R(i,j))


If:


v>R(x,y)


propagate update.
```
---

## Step 6

After reconstruction:

```scilab
BW=(I-R)>0
```

Pixels preserved after reconstruction become regional maxima.

---

# Full Algorithm

```text
Input image I

Create marker:
J=I−1

Initialize:
R=J

Create queue

Insert candidate pixels

while queue not empty

      pop pixel

      visit neighbors

      compute:

      v=min(mask,R)

      if improved:

             update

             push neighbor

end

BW=(I-R)>0
```

---

# Reconstruction Visualization

Original:

```text
2 2 2 2
2 8 8 2
2 8 8 2
2 2 2 2
```

Marker:

```text
1 1 1 1
1 7 7 1
1 7 7 1
1 1 1 1
```

After reconstruction:

```text
2 2 2 2
2 7 7 2
2 7 7 2
2 2 2 2
```

Difference:

```text
0 0 0 0
0 1 1 0
0 1 1 0
0 0 0 0
```

Detected regional maximum:

```text
8-plateau
```

---

# Connectivity

Supported connectivity:

## 4-connected

```text
    X
X   P   X
    X
```

---

## 8-connected

```text
X   X   X
X   P   X
X   X   X
```

Default:

```scilab
conn=8
```

---

# Time Complexity
```
Image size:


N=rows\times cols


Each pixel enters queue a limited number of times.

Complexity:


O(N)

Linear time.
```
---

# Space Complexity
```
Queue:

Q_x,Q_y


Maximum:

N


Memory:

O(N)
```

---

# Optimization Techniques Used

## 1. Queue-Based Reconstruction

Avoids repeated image scans.

---

## 2. Preallocated Queue

Avoid:

```scilab
queue=[queue;new] 
```

which reallocates memory repeatedly.

Use:

```scilab
Qx=zeros(rows*cols,1)
Qy=zeros(rows*cols,1)
```

---

## 3. Candidate Filtering

Only pixels satisfying:

```scilab
R<mask
```

are inserted.

Reduces unnecessary processing.

---

## 4. Connectivity Lookup

Neighbor offsets are precomputed:

```scilab
dx=[...]
dy=[...]
```

avoiding repeated branching.

---

## 5. Single-Pass Propagation

Pixels update neighbors directly.

No recursive calls.

No flood-fill stack overhead.

---

# Comparison with Naive Implementation

 Method                Complexity       Memory  Multiple scans 

- Neighbor Iteration  -->  O(kN)   -->    O(N)    Yes            
- Flood Fill         -->   O(kN)   -->    O(N)    Yes            
- Reconstruction Queue -->  O(N)   -->     O(N)    No             

---


# Research References

Vincent, L., Soille, P.

Watersheds in Digital Spaces:
An Efficient Algorithm Based on Immersion Simulations

1991

---


