kFoldKNN<-function(mltrain,k){
  index=matrix(sample(1:170),10,17)
  err=0
  for (i in 1:10){
    temptrain=mltrain[-index[i,],]
    temptest=mltrain[index[i,],]
    ytrain=temptrain$V1
    ytest=temptest$V1
    temptrain=subset(temptrain, select=-V1)
    temptest=subset(temptest, select=-V1)
    pred=knn(temptrain,temptest,k=k, cl=ytrain)
    err=err+sum(pred!=ytest)/length(pred)
  }
  err=err/10
  return(err)
}

TuneKNN<-function(mltrain){
  errold=1
  a=0
  v=numeric(50)
  for (i in seq(1,50)){
    err=kFoldKNN(mltrain,i)
    v[i]=err
    if (err<errold){
      a=i
      errold=err
    }
  }   
  return(list("k"=a, "vector"=v))
}

TesterrorKNN<-function(mldata,index) {
  #index=sample(nrow(mldata), size=40)
  mldatatrain=mldata[-index,]
  mldatatest=mldata[index,]
  a=TuneKNN(mldatatrain)
  ytrain=mldatatrain$V1
  ytest=mldatatest$V1
  mldatatrain=subset(mldatatrain,select=-V1)
  mldatatest=subset(mldatatest,select=-V1)
  predtrain=knn(mldatatrain,mldatatrain,ytrain)
  errtrain=sum(predtrain!=ytrain)/170
  aucvtrain=numeric(30)
  classes=c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36)
  for (i in 1:30){ 
    roctrain=roc(as.numeric(ytrain==classes[i]),as.numeric(predtrain==classes[i]))
    aucvtrain[i]=auc(roctrain)
  }
  auctrain=mean(aucvtrain)
  
  
  predtest=knn(mldatatrain,mldatatest,ytrain)
  errtest=sum(predtest!=ytest)/170
  aucvtest=numeric(30)
  for (i in 1:30){ 
    roctest=roc(as.numeric(ytest==classes[i]),as.numeric(predtest==classes[i]))
    aucvtest[i]=auc(roctest)
  }
  auctest=mean(aucvtest)
  print(paste('KNN:', 'error (train) is', errtrain,'auc (test) is', auctrain,'error (test) is', errtest, 'auc (test) is', auctest, 'k is', a$k))
  return(a$vector) 
}
