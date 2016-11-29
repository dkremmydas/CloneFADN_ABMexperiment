set f /f1*f10/;
alias(ff,f);

parameter test(f) /f1 4,f2 5,f3 6,f4 7,f5 8,f6 9,f7 10,f8 11,f9 12,f10 13/;
parameter test2(f);

set m(f,ff) /f1.f1,f2.f1,f3.f1,f4.f2,f5.f2,f6.f2,f7.f2,f8.f2,f9.f3,f10.f3/;
display f, m,test;

parameter f1,f2;

loop((f,ff),
  f1=f.ord;f2=ff.ord;
  display f1,f2,test;
  test2(f)$(m(f,ff))=test(ff);
  display test;
);

 display test2;
test(f)=test2(f);
display test;