
function err = immse(A, B)
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
