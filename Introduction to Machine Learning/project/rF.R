

kFoldrf<-function(mltrain, mtry, ntree){
index=matrix(sample(1:170),10,17)
err=0
for (i in 1:10){
  temptrain=mltrain[-index[i,],]
  temptest=mltrain[index[i,],]
  rf=randomForest(V1~., data=temptrain, mtry=mtry, ntree=ntree)
  pred=predict(rf,newdata=temptest)
  err=err+sum(pred!=temptest$V1)/length(temptest$V1)
}
err=err/10
return(err)
}

TuneRf<-function(mltrain, mtry){
  errold=1
  v=numeric(50)
  j=1
for (i in seq(1,500,10)){
    err=kFoldrf(mltrain, mtry,i)
    v[j]=err
    j=j+1;
    if (err<errold){
      errold=err
      a=i
    }
}   
return(list("vector"=v, "ntree"= a)) 
}

TesterrorRf<-function(mldata,mtry,index){
  #index=sample(nrow(mldata), size=140)
  mldatatrain=mldata[-index,]
  mldatatest=mldata[index,]
  a=TuneRf(mldatatrain, mtry)
  rf=randomForest(V1~., data=mldatatrain, mtry=mtry, ntree=a$ntree)
  predtrain=predict(rf,newdata=mldatatrain)
  errtrain=sum(predtrain!=mldatatrain$V1)/length(mldatatrain$V1)
  aucvtrain=numeric(30)
  classes=c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36)
  for (i in 1:30){ 
    roctrain=roc(as.numeric(mldatatrain$V1==classes[i]),as.numeric(predtrain==classes[i]))
    aucvtrain[i]=auc(roctrain)
  }
  auctrain=mean(aucvtrain)
  predtest=predict(rf,newdata=mldatatest)
  errtest=sum(predtest!=mldatatest$V1)/length(mldatatest$V1)
  aucvtest=numeric(30)
  for (i in 1:30){ 
    roctest=roc(as.numeric(mldatatest$V1==classes[i]),as.numeric(predtest==classes[i]))
    aucvtest[i]=auc(roctest)
  }
  auctest=mean(aucvtest)
  
  print(paste('Random forest:', 'error (train) is', errtrain,'auc (train) is', auctrain,'error (test) is', errtest, 'auc (test) is', auctest, 'cost', a$cost,'with B=',a$ntree,"and k=",mtry))
  return(a$vector) 
}
