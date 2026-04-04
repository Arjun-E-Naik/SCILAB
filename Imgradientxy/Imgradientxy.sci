
function [Gx, Gy] = imgradientxy(I, method)
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
