kFoldLsvm<-function(mltrain,cost){
  index=matrix(sample(1:170),10,17)
  err=0
  for (i in 1:10){
    temptrain=mltrain[-index[i,],]
    temptest=mltrain[index[i,],]
    psvm=svm(V1~., data=temptrain,kernel='linear')
    pred=predict(psvm,newdata=temptest)
    err=err+sum(pred!=temptest$V1)/length(temptest$V1)
  }
  err=err/10
  return(err)
}

TuneLsvm<-function(mltrain){
  errold=1
  a=c(0,0)
  v=numeric(50)
  j=1
  for (i in seq(25,75)/50){
    err=kFoldLsvm(mltrain,i)
    v[j]=err
    j=j+1
    if (err<errold){
      a=i
      errold=err
    }
  }   
  return(list("cost"=a, "vector"=v))
}

TesterrorLsvm<-function(mldata,index) {
  mldatatrain=mldata[-index,]
  mldatatest=mldata[index,]
  a=TuneLsvm(mldatatrain)
  lsvm=svm(V1~., data=mldatatrain, cost=a$cost,kernel='linear')
  predtrain=predict(lsvm,newdata=mldatatrain)
  errtrain=sum(predtrain!=mldatatrain$V1)/length(mldatatrain$V1)
  aucvtrain=numeric(30)
  classes=c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36)
  for (i in 1:30){ 
    roctrain=roc(as.numeric(mldatatrain$V1==classes[i]),as.numeric(predtrain==classes[i]))
    aucvtrain[i]=auc(roctrain)
  }
  auctrain=mean(aucvtrain)
  
  
  predtest=predict(lsvm,newdata=mldatatest)
  errtest=sum(predtest!=mldatatest$V1)/length(mldatatest$V1)
  aucvtest=numeric(30)
  for (i in c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36)){ 
    roctest=roc(as.factor(mldatatest$V1==i),as.numeric(predtest==i))
    aucvtest[i]=auc(roctest)
  } 
  auctest=mean(aucvtest)
  print(paste('Linear svm:', 'error (train) is', errtrain,'auc (test) is', auctrain,'error (test) is', errtest, 'auc (test) is', auctest, 'cost', a$cost))

  return(a$vector) 
}
