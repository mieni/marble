program cell
integer :: seed
integer :: i,j
integer :: n,N0
integer :: t						!CA step
integer :: n_i,n_ex		!number of steps for each process
integer :: array(500,500)				!array of cells
integer :: x0,y0,x1,y1,x2,y2			!position of the 									!vacancy and its 									!neighbours
integer, dimension (:,:), allocatable :: vac 	!positions of   
									!the vacanancies
integer :: step				!step for writing to files
integer :: val				!value assigned to a rule
integer :: difexi(3)			!CA rules
integer :: difexin(3,3)
integer :: Nv				!number of vacancies
real*8 :: Cv				!concentration of the vacancies
real*8 :: P_v			!probability of vertical exclusion
real*8 :: r				!random number
character(len=1024) :: file1,file2,file3	!file names
call randomize()
step=1
Cv=1./3.
P_v=0.5
Nv=0
n_i=1	!number of isotropic diffusion steps within one CA step
n_ex=6	!number of vacancy exclusion
difexi(1)=0		!isotropic diffusion rules
difexi(2)=-1
difexi(3)=-2
difexin(1,1)=0		!exclusion rules
difexin(1,2)=0
difexin(1,3)=0
difexin(2,1)=0
difexin(2,2)=-1
difexin(2,3)=0
difexin(3,1)=0
difexin(3,2)=0
difexin(3,3)=-2
do i=1,500					!initializing the array
do j=1,500
r=ran2(idum)
if(r<Cv) then
array(i,j)=0				!vacancy
Nv=Nv+1
else
r=ran2(idum)
if(r<0.5) then
array(i,j)=1				!PbTe
else
array(i,j)=2				!CdTe
end if
end if
end do
end do
allocate(vac(Nv,2))
n=1
do i=1,500
do j=1,500
if(array(i,j)==0) then
vac(n,1)=i
vac(n,2)=j
n=n+1
end if
end do
end do
do t=0,1000000000
if(modulo(t,step)==0) then			!writing to files
write(file1,"(A6,I0)")"PbTe_t",t
write(file2,"(A6,I0)")"CdTe_t",t
write(file3,"(A5,I0)")"vac_t",t
open(unit=1,file=file1)
open(unit=2,file=file2)
open(unit=3,file=file3)
do i=1,500
do j=1,500
if(array(i,j)==1) then
write(1,*),i,j
else if(array(i,j)==2) then
write(2,*),i,j
else if(array(i,j)==0) then
write(3,*),i,j
end if
end do
end do
close(1)
close(2)
close(3)
if((t/=0).AND.(modulo(t,10*step)==0)) then
step=10*step
end if
end if
do n=1,n_i*Nv					!isotropic diffusion
r=ran2(idum)
N0=int(r*Nv)+1
x0=vac(N0,1)
y0=vac(N0,2)
r=ran2(idum)
if(r<0.25) then
x1=x0+1
if(x1==501) then
x1=1
end if
y1=y0
else if(r<0.5) then
x1=x0
y1=y0+1
if(y1==501) then
y1=1
end if
else if(r<0.75) then
x1=x0-1
if(x1==0) then
x1=500
end if
y1=y0
else
x1=x0
y1=y0-1
if(y1==0) then
y1=500
end if
end if
val=difexi(array(x1,y1)+1)
array(x0,y0)=array(x0,y0)-val
array(x1,y1)=array(x1,y1)+val
if(array(x0,y0)/=0) then
vac(N0,1)=x1
vac(N0,2)=y1
end if
end do
do n=1,n_ex*Nv					!vacancy exclusion
r=ran2(idum)
N0=int(r*Nv)+1
x0=vac(N0,1)
y0=vac(N0,2)
r=ran2(idum)			!choosing vertical or horizontal direction
if(r<P_v) then		!choosing vertical neighbours
x1=x0
y1=y0-1
if(y1==0) then
y1=500
end if
x2=x0
y2=y0+1
if(y2==501) then
y2=1
end if
else				!horizontal neighbours
x1=x0-1
if(x1==0) then
x1=500
end if
y1=y0
x2=x0+1
if(x2==501) then
x2=1
end if
y2=y0
end if
val=difexin(array(x1,y1)+1,array(x2,y2)+1)
array(x0,y0)=array(x0,y0)-val
r=ran2(idum)
if(r<0.5) then
array(x1,y1)=array(x1,y1)+val
else
array(x2,y2)=array(x2,y2)+val
end if
if(array(x0,y0)/=0) then
if(array(x1,y1)==0) then
vac(N0,1)=x1
vac(N0,2)=y1
else if(array(x2,y2)==0) then
vac(N0,1)=x2
vac(N0,2)=y2
end if
end if
end do
end do
deallocate(vac)
end program cell

subroutine randomize
integer jtime(3), idum, idum2, idum3
real r, ran2
common /sxx/ idum
call itime(jtime)
idum = (jtime(1)+1)*(jtime(2)+2)+(jtime(2)+10)*(jtime(3)+13)+(jtime(1)+21)*(jtime(3)+123)
idum = - idum
r = ran2(idum)
return
end	

FUNCTION ran2(idum)
INTEGER idum,IM1,IM2,IMM1,IA1,IA2,IQ1,IQ2,IR1,IR2,NTAB,NDIV
REAL ran2,AM,EPS,RNMX
PARAMETER (IM1=2147483563,IM2=2147483399,AM=1./IM1,IMM1=IM1-1,IA1=40014,IA2=40692,IQ1=53668,IQ2=52774)
PARAMETER (IR1=12211,IR2=3791,NTAB=32,NDIV=1+IMM1/NTAB,EPS=1.2e-7,RNMX=1.-EPS)
INTEGER idum2,j,k,iv(NTAB),iy
SAVE iv,iy,idum2
DATA idum2/123456789/, iv/NTAB*0/, iy/0/
if (idum.le.0) then
idum=max(-idum,1)
idum2=idum
do 11 j=NTAB+8,1,-1
k=idum/IQ1
idum=IA1*(idum-k*IQ1)-k*IR1
if (idum.lt.0) idum=idum+IM1
if (j.le.NTAB) iv(j)=idum
11      continue
iy=iv(1)
endif
k=idum/IQ1
      idum=IA1*(idum-k*IQ1)-k*IR1
      if (idum.lt.0) idum=idum+IM1
      k=idum2/IQ2
      idum2=IA2*(idum2-k*IQ2)-k*IR2
      if (idum2.lt.0) idum2=idum2+IM2
      j=1+iy/NDIV
      iy=iv(j)-idum2
      iv(j)=idum
      if(iy.lt.1)iy=iy+IMM1
      ran2=min(AM*iy,RNMX)
      return
      END