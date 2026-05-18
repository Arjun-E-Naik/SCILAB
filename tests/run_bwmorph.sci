// tests/run_bwmorph_demo.sci
// Load the implementation so the function is available in this script
exec('bwmorph/bwmorph_new_clean.sci');

bw = zeros(7,7);
bw(3:5,3:5) = 1;
out = bwmorph_new(bw, 'thin');
disp(out);
exit();