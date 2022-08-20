

kFoldRsvm<-function(mltrain, cost, gamma ){
  index=matrix(sample(1:170),10,17)
  err=0
  for (i in 1:10){
    temptrain=mltrain[-index[i,],]
    temptest=mltrain[index[i,],]
    rsvm=svm(V1~., data=temptrain, cost=cost , gamma=gamma, kernel='radial')
    pred=predict(rsvm,newdata=temptest)
    err=err+sum(pred!=temptest$V1)/length(temptest$V1)
  }
  err=err/10
  return(err)
}

TuneRsvm<-function(mltrain,gamma){
  errold=1
  a=c(0,0)
  v=numeric(50)
  j=1
  for (i in seq(25,75)/50){
      err=kFoldRsvm(mltrain,i, gamma)
      v[j]=err
      j=j+1
      if (err<errold){
        a=i
        errold=err
      }
  }   
  return(list("cost"=a, "vector"=v))
}

TesterrorRsvm<-function(mldata,gamma, index) {
  #index=sample(nrow(mldata), size=40)
  mldatatrain=mldata[-index,]
  mldatatest=mldata[index,]
  a=TuneRsvm(mldatatrain,gamma)
  rsvm=svm(V1~., data=mldatatrain, kernel='radial', gamma=gamma, cost=a$cost)
  predtrain=predict(rsvm,data=mldatatrain)
  errtrain=sum(predtrain!=mldatatrain$V1)/length(mldatatrain$V1)
  aucvtrain=numeric(30)
  classes=c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36)
  for (i in 1:30){ 
    roctrain=roc(as.numeric(mldatatrain$V1==classes[i]),as.numeric(predtrain==classes[i]))
    aucvtrain[i]=auc(roctrain)
  }
  auctrain=mean(aucvtrain)
  
  predtest=predict(rsvm,newdata=mldatatest)
  errtest=sum(predtest!=mldatatest$V1)/length(mldatatest$V1)
  aucvtest=numeric(30)
  for (i in 1:30){ 
    roctest=roc(as.numeric(mldatatest$V1==classes[i]),as.numeric(predtest==classes[i]))
    aucvtest[i]=auc(roctest)
  }
  auctest=mean(aucvtest)
  print(paste('Radial svm:', 'error (train) is', errtrain,'auc (test) is', auctrain,'error (test) is', errtest, 'auc (test) is', auctest, 'cost', a$cost,'gamma', gamma))
  return(a$vector) 
}
