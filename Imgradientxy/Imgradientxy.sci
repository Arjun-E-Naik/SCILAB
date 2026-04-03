
// imgradientxy.sce — Directional Image Gradients (Gx and Gy)
// Equivalent to Octave image package: imgradientxy()


function [Gx, Gy] = imgradientxy(I, method)
// imgradientxy - Compute x and y directional gradients of a grayscale image
//
// Calling Sequence:
//   [Gx, Gy] = imgradientxy(I)
//   [Gx, Gy] = imgradientxy(I, method)
//
// Parameters:
//   : 2-D grayscale image matrix (double or integer type)
//   method : String (optional, default 'sobel'). One of:
// 'sobel'        — 3×3 Sobel operator (default)
// 'prewitt'      — 3×3 Prewitt operator
// 'central'      — Central differences
// 'intermediate' — Forward differences
//   Gx     : Horizontal gradient matrix (same size as I)
//   Gy     : Vertical gradient matrix (same size as I)
//
// Description:
//   Gx > 0 : intensity increases left to right
//   Gy > 0 : intensity increases top to bottom
//   Border pixels use replicate padding for convolution methods.

    if argn(2) < 2 then
        method = 'sobel';
    end

    if ndims(I) ~= 2 then
        error("imgradientxy: input I must be a 2-D grayscale matrix.");
    end

    I = double(I);
    [rows, cols] = size(I);

    select method

    case 'sobel'
        kx = [-1  0  1; -2  0  2; -1  0  1];
        ky = [-1 -2 -1;  0  0  0;  1  2  1];

    case 'prewitt'
        kx = [-1  0  1; -1  0  1; -1  0  1];
        ky = [-1 -1 -1;  0  0  0;  1  1  1];

    case 'central'
        Gx = zeros(rows, cols);
        Gy = zeros(rows, cols);
        for i = 1:rows
            for j = 1:cols
                jp = min(j+1, cols); jm = max(j-1, 1);
                ip = min(i+1, rows); im = max(i-1, 1);
                Gx(i,j) = (I(i,jp) - I(i,jm)) / (jp - jm);
                Gy(i,j) = (I(ip,j) - I(im,j)) / (ip - im);
            end
        end
        return;

    case 'intermediate'
        Gx = zeros(rows, cols);
        Gy = zeros(rows, cols);
        for i = 1:rows
            for j = 1:cols
                jp = min(j+1, cols);
                ip = min(i+1, rows);
                Gx(i,j) = I(i,jp) - I(i,j);
                Gy(i,j) = I(ip,j) - I(i,j);
            end
        end
        return;

    else
        error("imgradientxy: unknown method '" + method + "'. Use sobel, prewitt, central, or intermediate.");
    end

    // Replicate-pad image by 1 pixel on all sides
    I_pad = [I(1,1),    I(1,:),    I(1,cols);
             I(:,1),    I,         I(:,cols);
             I(rows,1), I(rows,:), I(rows,cols)];

    Gx = zeros(rows, cols);
    Gy = zeros(rows, cols);
    for i = 1:rows
        for j = 1:cols
            patch    = I_pad(i:i+2, j:j+2);
            Gx(i,j)  = sum(sum(kx .* patch));
            Gy(i,j)  = sum(sum(ky .* patch));
        end
    end

endfunction


// TEST CASES


disp("  imgradientxy — Test Cases");


// Test 1: Constant image ->- both gradients zero
I1 = 100 * ones(5,5);
[Gx1, Gy1] = imgradientxy(I1);
printf("Test 1 [Constant image Sobel]     : max|Gx|=%.1f  max|Gy|=%.1f  (expected 0, 0)\n", max(abs(Gx1(:))), max(abs(Gy1(:))));

// Test 2: Vertical edge ->- large Gx, zero Gy
I2 = [zeros(5,3), 255*ones(5,3)];
[Gx2, Gy2] = imgradientxy(I2, 'sobel');
printf("Test 2 [Vertical edge Sobel]      : max|Gx|=%.1f (large), max|Gy|=%.1f (expected 0)\n", max(abs(Gx2(:))), max(abs(Gy2(:))));

// Test 3: Horizontal edge → large Gy, zero Gx
I3 = [zeros(3,5); 255*ones(3,5)];
[Gx3, Gy3] = imgradientxy(I3, 'sobel');
printf("Test 3 [Horizontal edge Sobel]    : max|Gx|=%.1f (expected 0), max|Gy|=%.1f (large)\n", max(abs(Gx3(:))), max(abs(Gy3(:))));

// Test 4: Prewitt on horizontal ramp ->- uniform Gx, Gy=0
I4 = zeros(5,5);
for j = 1:5, I4(:,j) = j*10; end
[Gx4, Gy4] = imgradientxy(I4, 'prewitt');
printf("Test 4 [Ramp Prewitt]             : Gx(3,3)=%.1f  max|Gy|=%.1f  (expected 60, 0)\n", Gx4(3,3), max(abs(Gy4(:))));

// Test 5: Central differences on [1 to9] matrix
I5 = [1 2 3; 4 5 6; 7 8 9];
[Gx5, Gy5] = imgradientxy(I5, 'central');
printf("Test 5 [Central diff [1..9]]      : Gx(2,2)=%.1f  Gy(2,2)=%.1f  (expected 1, 3)\n", Gx5(2,2), Gy5(2,2));



quit
