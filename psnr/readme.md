
# PSNR - Peak Signal-to-Noise Ratio for Scilab

### Overview
The Peak Signal-to-Noise Ratio (PSNR) is an objective fidelity metric used to quantify the quality of a reconstructed or compressed image `A` compared to a reference image `ref_img`. Higher PSNR values generally indicate better quality and lower distortion.

While GNU Octave provides a built-in `psnr()` function in the `image` package, Scilab does not include a native implementation. This repository provides a compatible `psnr()` function for Scilab with extended features.

###  Features 
-  Automatic peak value detection  based on image data types.
-  RGB image support : Computes MSE across all channels and averages for a single PSNR value.
-  Flexible interface : Optional `peakval` argument for custom dynamic range.
-  Robust warnings : Alerts when `mse = 0`, indicating identical images.
-  Output : Returns both `peaksnr` and `mse` for complete analysis.

###  Function Syntax 
[peaksnr, mse] = psnr(A, ref_img)
[peaksnr, mse] = psnr(A, ref_img, peakval)


###  Parameters 
Parameter | Type | Description
`A` | `uint8`, `uint16`, `double` matrix | Distorted/test image. Supports grayscale or RGB.
`ref_img` | Same type/size as `A` | Reference image. Must have identical dimensions to `A`.
`peakval` | `double`, optional | Maximum possible pixel value. If omitted, inferred from `A` data type.


###  Returns 
Variable | Type | Description
`peaksnr` | `double` | PSNR value in dB. Returns `%inf` if images are identical.
`mse` | `double` | Mean Squared Error between `A` and `ref_img`.


###  Algorithm 
1.  Input Validation : 
   - Check that `A` and `ref_img` are numeric matrices with identical size.
   - Validate `peakval` if provided.

2.  Data Type Conversion : Convert inputs to `double` precision for computation.

3.  MSE Computation :
   -  Grayscale : `mse = mean((A(:) - ref_img(:)).^2)`
   -  RGB : Compute MSE per channel, then `mse = mean(mse_channels)`

4.  PSNR Computation :
   if mse == 0 then
       peaksnr = %inf
       warning("Input images are identical. PSNR is infinite.")
   else
       peaksnr = 10   log10(peakval^2 / mse)
   end


5.  Return : `[peaksnr, mse]`

###  Usage Examples 
```
// Load images
ref = imread('original.png');
noisy = imread('compressed.png');

// Basic usage - auto peak detection
[psnr_val, mse_val] = psnr(noisy, ref);
disp("PSNR: " + string(psnr_val) + " dB");

// With custom peak value for normalized data
A_double = double(ref) / 255;
B_double = double(noisy) / 255;
[psnr_val, mse_val] = psnr(B_double, A_double, 1.0);
```
###  Testing 
Unit tests covering grayscale, RGB, identical images, and data type edge cases are provided in `test_psnr.sci`.

Run tests:
exec('test_psnr.sci', -1)


