exec("stdfilt.sci",-1);

disp("Test: 01");

I=rand(5,5);

J=stdfilt(I);

disp(J)


disp("Test: 02");

I=rand(10,10);

N=ones(5,5);

J=stdfilt(I,N);

disp(size(J))

// out put 10 10

disp("Test: 03");

I=rand(6,6);

N=1;

J=stdfilt(I,N);

disp(J)

// out: all zeros


disp("Test: 04");
I=ones(10,10)*5;

J=stdfilt(I);

disp(max(J))
// 0



disp("Test: 05");

I=[0 0 0 1 1;
   0 0 1 1 1;
   0 1 1 1 0;
   1 1 1 0 0;
   1 1 0 0 0];

J=stdfilt(I);

disp(J)


disp("Test: 06");

I=uint8(rand(20,20)*255);

J=stdfilt(I);

disp(typeof(J))


disp("Test: 07");

I=rand(512,512);

tic()
J=stdfilt(I);
t=toc();

disp(t)


disp("Test: 08");
I=rand(20,20);

N=ones(3,5);

J=stdfilt(I,N);

disp(size(J))


disp("Test: 09");
I=rand(10,10);

N=[0 1 0;
   1 1 1;
   0 1 0];

J=stdfilt(I,N);

disp(J)