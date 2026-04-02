// =============================================================================
// test_immse.sce — Standalone test runner for immse
// Run: scilab-cli -nb -f tests/test_immse.sce
// Load function from source
function err = immse(A, B)
    if argn(2) ~= 2 then
        error("immse: exactly two input arguments required.");
    end
    if ~isequal(size(A), size(B)) then
        error("immse: A and B must have the same size.");
    end
    A = double(A); B = double(B);
    d = A - B;
    err = mean(d .* d);
endfunction

passed = 0;
failed = 0;

function [p,f] = check(label, got, expected, tol, p, f)
    if abs(got - expected) <= tol then
        printf("  ✓ PASS  %s : %.6f\n", label, got);
        p = p + 1;
    else
        printf("  ✗ FAIL  %s : got=%.6f  expected=%.6f\n", label, got, expected);
        f = f + 1;
    end
endfunction

disp("─────────────────────────────────────");
disp("  TEST SUITE: immse");
disp("─────────────────────────────────────");

[passed,failed] = check("identical matrices", immse([1 2;3 4], [1 2;3 4]), 0,      1e-10, passed, failed);
[passed,failed] = check("zeros vs twos", immse([0 0;0 0], [2 2;2 2]), 4,      1e-10, passed, failed);
[passed,failed] = check("vector shift-1", immse([1 2 3 4 5], [2 3 4 5 6]), 1,      1e-10, passed, failed);
[passed,failed] = check("grayscale patches", immse([100 150;200 250], [110 140;190 255]), 81.25, 1e-10, passed, failed);
[passed,failed] = check("single element equal", immse([128], [128]), 0,      1e-10, passed, failed);

rand("seed", 99);
A = rand(20,20)*255; B = A;
[passed,failed] = check("large identical matrices", immse(A, B), 0,      1e-10, passed, failed);

[passed,failed] = check("negative values", immse([-5 -3], [-3 -5]), 4,      1e-10, passed, failed);
[passed,failed] = check("float precision", immse([0.1 0.2], [0.2 0.3]), 0.01,   1e-10, passed, failed);

disp("─────────────────────────────────────");
printf("  Results: %d passed, %d failed\n", passed, failed);
disp("─────────────────────────────────────");

if failed > 0 then
    exit(1);
else
    exit(0);
end
