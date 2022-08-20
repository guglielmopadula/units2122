library('randomForest')
library('naivebayes')
library('caret')
library('e1071')
mldata=read.csv('/home/cyberguli/Scaricati/mlproject/leaf.csv',header=FALSE)
mldata=mldata[,-2]
mldata$V1=as.factor(mldata$V1)
set.seed(200)
index=sample(nrow(mldata), size=40)
mldatatrain=mldata[-index,]
mldatatest=mldata[index,]

kFoldrf<-function(mltrain, mtry, ntree){
index=matrix(sample(1:300),10,30)
err=0
for (i in 1:10){
  temptrain=mltrain[-index[i,],]
  temptest=mltrain[index[i,],]
  rf=randomForest(V1~., data=temptrain, mtry=mtry, ntree=ntree)
  pred=predict(rf,newdata=temptest)
  err=err+sum(pred!=temptest$V1)/30
}
err=err/10
return(err)
}

TuneRf<-function(mltrain){
errold=1
a=c(0,0)
for (i in seq(1,500,50)){
  for (j in seq(1,ncol(mltrain)-1,1)){
    err=kFoldrf(mltrain,j,i)
    if (err<errold){
      a=c(i,j)
    }
  }
}   
return(a) 
}

a=TuneRf(mldatatrain)
