
// test_imgradientxy.sce — Standalone test runner for imgradientxy
// Run: scilab-cli -nb -f tests/test_imgradientxy.sce


function [Gx, Gy] = imgradientxy(I, method)
    if argn(2) < 2 then method = 'sobel'; end
    if ndims(I) ~= 2 then
        error("imgradientxy: input must be 2-D.");
    end
    I = double(I);
    [rows, cols] = size(I);
    select method
    case 'sobel'
        kx = [-1 0 1; -2 0 2; -1 0 1];
        ky = [-1 -2 -1; 0 0 0; 1 2 1];
    case 'prewitt'
        kx = [-1 0 1; -1 0 1; -1 0 1];
        ky = [-1 -1 -1; 0 0 0; 1 1 1];
    case 'central'
        Gx = zeros(rows,cols); Gy = zeros(rows,cols);
        for i=1:rows, for j=1:cols
            jp=min(j+1,cols); jm=max(j-1,1);
            ip=min(i+1,rows); im=max(i-1,1);
            Gx(i,j)=(I(i,jp)-I(i,jm))/(jp-jm);
            Gy(i,j)=(I(ip,j)-I(im,j))/(ip-im);
        end, end
        return;
    case 'intermediate'
        Gx = zeros(rows,cols); Gy = zeros(rows,cols);
        for i=1:rows, for j=1:cols
            Gx(i,j)=I(i,min(j+1,cols))-I(i,j);
            Gy(i,j)=I(min(i+1,rows),j)-I(i,j);
        end, end
        return;
    else
        error("imgradientxy: unknown method.");
    end
    I_pad = [I(1,1),I(1,:),I(1,cols); I(:,1),I,I(:,cols); I(rows,1),I(rows,:),I(rows,cols)];
    Gx = zeros(rows,cols); Gy = zeros(rows,cols);
    for i=1:rows, for j=1:cols
        p = I_pad(i:i+2,j:j+2);
        Gx(i,j)=sum(sum(kx.*p));
        Gy(i,j)=sum(sum(ky.*p));
    end, end
endfunction

passed = 0;
failed = 0;

function [p,f] = check(label, got, expected, tol, p, f)
    if abs(got - expected) <= tol then
        printf("   PASS  %s : %.4f\n", label, got);
        p = p + 1;
    else
        printf("   FAIL  %s : got=%.4f  expected=%.4f\n", label, got, expected);
        f = f + 1;
    end
endfunction


disp("  TEST SUITE: imgradientxy");


// Test 1: Constant → zero gradients
[Gx,Gy] = imgradientxy(100*ones(5,5));
[passed,failed] = check("constant image Gx=0", max(abs(Gx(:))), 0, 1e-10, passed, failed);
[passed,failed] = check("constant image Gy=0", max(abs(Gy(:))), 0, 1e-10, passed, failed);

// Test 2: Vertical edge → large Gx
I2 = [zeros(5,3), 255*ones(5,3)];
[Gx2,Gy2] = imgradientxy(I2,'sobel');
[passed,failed] = check("vertical edge max|Gx|>0", max(abs(Gx2(:))), 1020, 1, passed, failed);
[passed,failed] = check("vertical edge max|Gy|=0", max(abs(Gy2(:))), 0, 1e-10, passed, failed);

// Test 3: Horizontal edge → large Gy
I3 = [zeros(3,5); 255*ones(3,5)];
[Gx3,Gy3] = imgradientxy(I3,'sobel');
[passed,failed] = check("horizontal edge max|Gx|=0", max(abs(Gx3(:))), 0, 1e-10, passed, failed);
[passed,failed] = check("horizontal edge max|Gy|>0", max(abs(Gy3(:))), 1020, 1, passed, failed);

// Test 4: Prewitt ramp
I4 = zeros(5,5);
for j=1:5, I4(:,j)=j*10; end
[Gx4,Gy4] = imgradientxy(I4,'prewitt');
[passed,failed] = check("prewitt ramp Gx(3,3)=60", Gx4(3, 3), 60, 1e-10, passed, failed);
[passed,failed] = check("prewitt ramp max|Gy|=0", max(abs(Gy4(:))), 0, 1e-10, passed, failed);

// Test 5: Central diff interior values
I5 = [1 2 3; 4 5 6; 7 8 9];
[Gx5,Gy5] = imgradientxy(I5,'central');
[passed,failed] = check("central diff Gx(2,2)=1", Gx5(2, 2), 1, 1e-10, passed, failed);
[passed,failed] = check("central diff Gy(2,2)=3", Gy5(2, 2), 3, 1e-10, passed, failed);

// Test 6: Output size same as input
I6 = rand(7,9)*100;
[Gx6,Gy6] = imgradientxy(I6,'sobel');
sz_ok = isequal(size(Gx6), size(I6)) & isequal(size(Gy6), size(I6));
if sz_ok then
    printf("   PASS  output size matches input : [%d %d]\n", size(Gx6,1), size(Gx6,2));
    passed = passed + 1;
else
    printf("   FAIL  output size mismatch\n");
    failed = failed + 1;
end

// Test 7: Intermediate differences on identity
I7 = eye(4,4)*100;
[Gx7,Gy7] = imgradientxy(I7,'intermediate');
[passed,failed] = check("intermediate not all zero Gx", max(abs(Gx7(:))) > 0, 1, 1e-10, passed, failed);


printf("  Results: %d passed, %d failed\n", passed, failed);


if failed > 0 then
    exit(1);
else
    exit(0);
end
