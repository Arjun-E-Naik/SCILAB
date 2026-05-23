
exec("bweuler.sci",-1);

// Single object
BW=[0 0 0;
    0 1 0;
    0 0 0];

disp(bweuler_fast(BW))
// 1


// Two objects
BW=[1 0 1];

disp(bweuler_fast(BW))
// 2


// Ring object
BW=[0 1 1 1 0;
    1 0 0 0 1;
    1 0 0 0 1;
    1 0 0 0 1;
    0 1 1 1 0];

disp(bweuler_fast(BW))
//0


// Nested structure
BW=[1 1 1 1 1;
    1 0 0 0 1;
    1 0 1 0 1;
    1 0 0 0 1;
    1 1 1 1 1];

disp(bweuler_fast(BW))
//1


// Diagonal test
BW=[1 0;
    0 1];

disp(bweuler_fast(BW,8))
disp(bweuler_fast(BW,4))