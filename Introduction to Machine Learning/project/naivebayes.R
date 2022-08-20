TesterrorBayes<-function(mldata, index) {
  mldatatrain=mldata[-index,]
  mldatatest=mldata[index,]
  bayes=naiveBayes(V1~., data=mldatatrain)
  predtrain=predict(bayes,newdata=mldatatrain)
  errtrain=sum(predtrain!=mldatatrain$V1)/length(mldatatrain$V1)
  aucvtrain=numeric(30)
  classes=c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36)
  for (i in 1:30){ 
    roctrain=roc(as.numeric(mldatatrain$V1==classes[i]),as.numeric(predtrain==classes[i]))
    aucvtrain[i]=auc(roctrain)
  }
  

  auctrain=mean(aucvtrain)
  
  predtest=predict(bayes,newdata=mldatatest)
  errtest=sum(predtest!=mldatatest$V1)/length(mldatatest$V1)
  aucvtest=numeric(30)
  for (i in 1:30){ 
    roctest=roc(as.numeric(mldatatest$V1==classes[i]),as.numeric(predtest==classes[i]))
    aucvtest[i]=auc(roctest)
  }
  auctest=mean(aucvtest)
  print(paste('Bayes:', 'error (train) is', errtrain,'auc (test) is', auctrain,'error (test) is', errtest, 'auc (test) is', auctest))
  return(errtest) 
}
