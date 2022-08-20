#!/usr/bin/env Rscript

isprime <- function(n) n == 2L || all(n %% 2L:ceiling(sqrt(n)) != 0)

data=read.csv("tree.csv")
x=1:24
y=1:24
z=matrix(0,24,24)
for (i in 1:length(data[,1])){
  z[data$omp[i],data$mpi[i]]=data$time[i]
}

ompweak=read.csv("weakomp.csv")
mpiweak=read.csv("weakmpi.csv")

extract <- function(num){
  k=0
  for (i in 1:num){
    for (j in 1:num){
      if (i*j==num){
        k=k+1;
      }
    }
  }
  
  
  v=matrix(0,k,3)
  k=1
  for (i in 1:num){
    for (j in 1:num){
      if (i*j==num){
        v[k,1]=i
        v[k,2]=z[i,j];
	v[k,3]=(2-1/j+(log2(100000000)-log2(j+1))/i)*100000000;
        k=k+1;
      }
    }
  }
  return(v);
  
}

empiv=(2-1/x+(log2(100000000)-log2(x+1)))*100000000;
eompv=empiv=(2-1/1+(log2(100000000)-log2(1+1))/y)*100000000;
mpiv=data[data$omp==1,]$time
ompv=data[data$mpi==1,]$time

for(i in 1:24){
if(isprime(i)==0 & i!=1){
if (i<10){
name=paste("data",0,i,".png",sep="")
}
else{
name=paste("data",i,".png",sep="")
}
png(name, type='cairo')
v=extract(i)
plot(v[,1],v[,2],xlab="number of omp threads",ylab="time of execution", col='blue', main=paste('costant number of mpi*omp threads (equal to ',i,')',sep=""))
mod=lm(v[,2]~v[,3]);
lines(v[,1],fitted(mod),col="red")
dev.off()
}
}

png("ompvsmpistrong.png",type='cairo')
plot(1:24, ompv,lty = 1, lwd = 1, col='red',type='b',pch = 19, xlab="number of cores used", ylab="time of execution", main="mpi vs omp strong scaling")
lines(1:24, mpiv,lty = 1, lwd = 1,col='blue',type='b',pch = 19)
legend(x="topright",legend=c("omp performance","mpi performance"),col=c("red","blue"),lty=c(1,1),pch=c(19,19))
dev.off()

png("strongomp.png",type='cairo')
plot(1:24, ompv,lty = 1, lwd = 1, col='blue', xlab="number of omp threads", ylab="time of execution", main="Strong omp scaling") 
mod=lm(ompv~eompv)
lines(1:24,fitted(mod),lty=1,lwd=1,col='red',type="b",pch=19);
legend(x="topright",legend=c("omp actual performance","omp fitted performance"),col=c("blue","red"),lty=c(1,1),pch=c(1,19))
dev.off()

png("strongmpi.png",type='cairo')
plot(1:24, mpiv,lty = 1, lwd = 1, col='blue', xlab="number of mpi threads", ylab="time of execution", main="Strong mpi scaling")
mod=lm(mpiv~empiv)
lines(1:24,fitted(mod),col='red',type='b',pch=19);
legend(x="topright",legend=c("mpi actual performance","mpi fitted performance"),col=c("blue","red"),lty=c(1,1),pch=c(1,19))
dev.off()



png("ompvsmpiweak.png",type='cairo')
plot(1:24, mpiweak[,2],lty = 1, lwd = 1, col='blue',type='b',pch = 19, xlab="number of cores used", ylab="time of execution", main="mpi vs omp weak scaling" )
lines(1:24, ompweak[,2],lty = 1, lwd = 1,col='red',type='b',pch = 19)
legend(x="topleft",legend=c("omp performance","mpi performance"),col=c("red","blue"),lty=c(1,1),pch=c(19,19))
dev.off()


n=5000000
mpi=1:24
xmpi=(2-2/(mpi)+log2(n)-log2(mpi+1))*n*mpi
ympi=mpiweak[,2]
modmpi=lm(ympi~xmpi)
png("weakmpi.png",type='cairo')
plot(1:24,ympi,col='blue',xlab="number of mpi threads", ylab="time of execution",main="Weak mpi scaling (constant workload per mpi thread)")
lines(1:24,fitted(modmpi),col='red',type="b",pch=19)
legend(x="topleft",legend=c("mpi actual performance","mpi fitted performance"),col=c("blue","red"),lty=c(1,1),pch=c(1,19))
dev.off()

n=5000000
omp=1:24
xomp=(1+(log2(n*omp)-log2(2))/omp)*n*omp
yomp=ompweak[,2]
modomp=lm(yomp~xomp)
png("weakomp.png",type='cairo')
plot(1:24,yomp,col='blue',xlab="number of omp threads", ylab="time of execution",main="Weak omp scaling (constant workload per omp thread)" )
lines(1:24,fitted(modomp),col='red',type="b",pch=19)
legend(x="topleft",legend=c("omp actual performance","omp fitted performance"),col=c("blue","red"),lty=c(1,1),pch=c(1,19))
dev.off()

ompalg=read.csv("ompalg.csv")
mpialg=read.csv("mpialg.csv")

png("ompalg.png", type='cairo')
ompalg0=ompalg[ompalg$alg==0,];
ompalg1=ompalg[ompalg$alg==1,];
ompalg2=ompalg[ompalg$alg==2,];
plot(1:24,ompalg0$time, xlab="omp threads", ylab="time", lty = 1, lwd = 1,col='blue',type='b',pch = 19,xlim=c(0,24), ylim=c(25,400), main="omp performance with different algorithms")
lines(1:24, ompalg1$time,lty = 1, lwd = 1,col='green',type='b',pch = 19)
lines(1:24, ompalg2$time,lty = 1, lwd = 1,col='red',type='b',pch = 19)
legend(x="topleft",legend=c("merge sort serial","merge sort parallel","quick select"),col=c("blue","green","red"),lty=c(1,1,1),pch=c(19,19,19))

dev.off()

png("mpialg.png", type='cairo')
mpialg0=mpialg[mpialg$alg==0,];
mpialg1=mpialg[mpialg$alg==1,];
mpialg2=mpialg[mpialg$alg==2,];
plot(1:24,mpialg0$time, xlab="mpi threads", ylab="time", lty = 1, lwd = 1,col='blue',type='b',pch = 19,xlim=c(0,24), ylim=c(25,400),main="mpi performance with different algorithms")
lines(1:24, mpialg1$time,lty = 1, lwd = 1,col='green',type='b',pch = 19)
lines(1:24, mpialg2$time,lty = 1, lwd = 1,col='red',type='b',pch = 19)
legend(x="topleft",legend=c("merge sort serial","merge sort parallel","quick select"),col=c("blue","green","red"),lty=c(1,1,1),pch=c(19,19,19))

dev.off()


vark=read.csv("varingk.csv")
png("vark.png", type='cairo')
plot(vark[,1],vark[,2], xlab="K", ylab="time", lty = 1, lwd = 1,col='blue',type='b',pch = 19,main="serial performance with different K (n=10000000)")
dev.off()
