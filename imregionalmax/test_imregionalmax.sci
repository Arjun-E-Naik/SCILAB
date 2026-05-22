exec("imregionalmax.sci",-1);

// isolated peak
disp("Isolated Peak");
I=[1 1 1;
   1 9 1;
   1 1 1];

disp(immaximas(I));


// plateau peak
disp("Plateau Peak");
I=[1 1 1 1;
   1 5 5 1;
   1 5 5 1;
   1 1 1 1];

disp(immaximas(I));

disp("Multiple Peak");
// multiple peaks

I=[1 7 1 8;
   2 1 3 1;
   9 1 4 2];

disp(immaximas(I));


// random large image
disp("Random Image");
I=grand(32,32,"uin",0,255);

tic();

BW=immaximas(I);

toc();