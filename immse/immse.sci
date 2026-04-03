
// immse.sce — Mean Squared Error between two images
// Equivalent to Octave image package: immse()

function err = immse(A, B)
// immse - Compute Mean Squared Error (MSE) between two images or arrays
//
// Calling Sequence:
//   err = immse(A, B)
//
// Parameters:
//   A   : Numeric matrix (any dimension) — first image/array
//   B   : Numeric matrix (same size as A) — second image/array
//   err : Scalar double — mean squared error between A and B
//
// Description:
//   MSE = mean( (A(:) - B(:)).^2 )
//   Inputs are cast to double before computation to prevent overflow.

    if argn(2) ~= 2 then
        error("immse: exactly two input arguments required.");
    end
    if ~isequal(size(A), size(B)) then
        error("immse: A and B must have the same size.");
    end

    A   = double(A);
    B   = double(B);
    d   = A - B;
    err = mean(d .* d);

endfunction




disp("  immse — Test Cases");


// Test 1: Identical matrices ->- MSE = 0
A1 = [1 2 3; 4 5 6; 7 8 9];
r1 = immse(A1, A1);
printf("Test 1 [Identical matrices]      : %.4f  (expected: 0.0000)\n", r1);

// Test 2: Uniform difference ->- MSE = 4
r2 = immse([0 0; 0 0], [2 2; 2 2]);
printf("Test 2 [Zeros vs twos 2×2]       : %.4f  (expected: 4.0000)\n", r2);

// Test 3: Vectors shifted by 1 ->- MSE = 1
r3 = immse([1 2 3 4 5], [2 3 4 5 6]);
printf("Test 3 [Vectors shifted by 1]    : %.4f  (expected: 1.0000)\n", r3);

// Test 4: Integer image patches ->- MSE = 81.25
// Differences: -10, 10, 10, -5  ->- squares: 100,100,100,25 → mean=81.25
A4 = double([100 150; 200 250]);
B4 = double([110 140; 190 255]);
r4 = immse(A4, B4);
printf("Test 4 [Grayscale patches]       : %.4f  (expected: 81.2500)\n", r4);

// Test 5: Noisy image (MSE > 0, small)
rand("seed", 42);
A5 = rand(10, 10) * 255;
B5 = A5 + rand(10, 10) * 10;
r5 = immse(A5, B5);
printf("Test 5 [Noisy image pair]        : %.4f  (expected: small positive)\n", r5);



quit
