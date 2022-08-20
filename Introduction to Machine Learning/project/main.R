library('randomForest')
library('naivebayes')
library('caret')
library('e1071')
library('pROC')
library('class')

#rf=0.275, 4=301, k=5
#rsvm=0.275, gamma=0.31
#psvm=0.3, degree=2
#lsvm=0.3
#bayes=0.175


set.seed(50)
source("~/MLproject/rF.R")
source("~/MLproject/linearsvm.R")
source("~/MLproject/naivebayes.R")
source("~/MLproject/radialsvm.R")
source("~/MLproject/polynomialsvm.R")
source("~/MLproject/sigmoidsvm.R")
source("~/MLproject/knn.R")
mldata=read.csv("~/MLproject/leaf.csv",header=FALSE)
mldata=mldata[,-2]
index = createDataPartition(as.factor(mldata$V1), p = 0.3, list = F)
mldata$V1=as.factor(mldata$V1)
mldatatrain=mldata[-index,]
mldatatest=mldata[index,]


# Rf1=TesterrorRf(mldata,1,index)
# Rf2=TesterrorRf(mldata,2,index)
# Rf3=TesterrorRf(mldata,3,index)
# Rf4=TesterrorRf(mldata,4,index)
# Rf5=TesterrorRf(mldata,5,index)
# B=seq(1,500,10)
# 
# Rf=data.frame(B,Rf1,Rf2,Rf3,Rf4,Rf5)
# 
# p=ggplot(data = Rf, aes(x = B))+theme(text = element_text(size = 25))
#   p=p+geom_line(aes(y = Rf1, colour = "mtry=1"))
#   p=p+geom_line(aes(y = Rf2, colour = "mtry=2"))
#   p=p+geom_line(aes(y = Rf3, colour = "mtry=3"))
#   p=p+geom_line(aes(y = Rf4, colour = "mtry=4"))
#   p=p+geom_line(aes(y = Rf5, colour = "mtry=5"))
#   p=p+scale_colour_manual("",
#                       breaks = c("mtry=1", "mtry=2", "mtry=3", "mtry=4", "mtry=5"),
#                       values = c("red", "green", "blue", "orange","black")) +
#   xlab(" B")
#   p=p+scale_y_continuous("10CV error", limits = c(0.2,0.7))
#   p=p+labs(title="Iterations of calculation of the variable B in different rf models")
#   print(p)
# 
# R1=TesterrorRsvm(mldata,0.10,index)
# R2=TesterrorRsvm(mldata,0.60,index)
# R3=TesterrorRsvm(mldata,1.10,index)
# R4=TesterrorRsvm(mldata,1.60,index)
# R5=TesterrorRsvm(mldata,2.10,index)
# 
# cost=seq(25,75)/50
# 
# Rsvm=data.frame(cost,R1,R2,R3,R4,R5)
# 
# p=ggplot(data = Rsvm, aes(x = cost))
# p=p+geom_line(aes(y = R1, colour = "gamma=0.1 (radial)"))
# p=p+geom_line(aes(y = R2, colour = "gamma=0.6 (radial)"))
# p=p+geom_line(aes(y = R3, colour = "gamma=1.1 (radial)"))
# p=p+geom_line(aes(y = R4, colour = "gamma=1.6 (radial)"))
# p=p+geom_line(aes(y = R5, colour = "gamma=2.1 (radial)"))
# p=p+scale_colour_manual("",
#                         breaks = c("gamma=0.1 (radial)","gamma=0.6 (radial)", "gamma=1.1 (radial)", "gamma=1.6 (radial)", "gamma=2.1 (radial)"),
#                         values = c("red", "green", "blue", "orange","black")) +
#   xlab(" cost")
# p=p+scale_y_continuous("10CV error", limits = c(0.25,0.85))
# p=p+labs(title="Iterations of calculation of the variable cost in different radial SVM models")
# print(p)
# 
# 
# 
# S1=TesterrorSsvm(mldata,0.10,index)
# S2=TesterrorSsvm(mldata,0.60,index)
# S3=TesterrorSsvm(mldata,1.10,index)
# S4=TesterrorSsvm(mldata,1.60,index)
# S5=TesterrorSsvm(mldata,2.10,index)
# 
# Ssvm=data.frame(cost,S1, S2,S3,S4,S5)
# 
# p=ggplot(data = Ssvm, aes(x = cost))
# p=p+geom_line(aes(y = S1, colour = "gamma=0.1 (sigmoid)"))
# p=p+geom_line(aes(y = S2, colour = "gamma=0.6 (sigmoid)"))
# p=p+geom_line(aes(y = S3, colour = "gamma=1.1 (sigmoid)"))
# p=p+geom_line(aes(y = S4, colour = "gamma=1.6 (sigmoid)"))
# p=p+geom_line(aes(y = S5, colour = "gamma=2.1 (sigmoid)"))
# p=p+scale_colour_manual("",
#                         breaks = c("gamma=0.1 (sigmoid)","gamma=0.6 (sigmoid)", "gamma=1.1 (sigmoid)", "gamma=1.6 (sigmoid)", "gamma=2.1 (sigmoid)"),
#                         values = c("white", "wheat", "cyan", "brown","pink")) +
#   xlab(" cost")
# p=p+scale_y_continuous("10CV error", limits = c(0,0.9))
# p=p+labs(title="Iterations of calculation of the variable cost in different sigmoid SVM models")
# print(p)
# 
# 
# 
# 
# 
#  P2=TesterrorPsvm(mldata,2,index)
#  P3=TesterrorPsvm(mldata,3,index)
#  L=TesterrorLsvm(mldata,index)
# 
#  Ssvm=data.frame(cost,L, P2,P3)
# 
#  p=ggplot(data = Ssvm, aes(x = cost))
#  p=p+geom_line(aes(y = L, colour = "linear"))
#  p=p+geom_line(aes(y = P2, colour = "quadratic"))
#  p=p+geom_line(aes(y = P3, colour = "cubic"))
#  p=p+scale_colour_manual("",
#                          breaks = c("linear","quadratic", "cubic"),
#                          values = c("greenyellow", "purple", "darkblue")) +
#    xlab(" cost")
#  p=p+scale_y_continuous("10CV error", limits = c(0.22,0.40))
#  p=p+labs(title="Iterations of calculation of the variable cost in different polynomial SVM models")
#  print(p)

# 
# R1=TesterrorRsvm(mldata,0.10,index)
# R2=TesterrorRsvm(mldata,0.60,index)
# R3=TesterrorRsvm(mldata,1.10,index)
# R4=TesterrorRsvm(mldata,1.60,index)
# R5=TesterrorRsvm(mldata,2.10,index)
# S1=TesterrorSsvm(mldata,0.10,index)
# S2=TesterrorSsvm(mldata,0.60,index)
# S3=TesterrorSsvm(mldata,1.10,index)
# S4=TesterrorSsvm(mldata,1.60,index)
# S5=TesterrorSsvm(mldata,2.10,index)
# P2=TesterrorPsvm(mldata,2,index)
# P3=TesterrorPsvm(mldata,3,index)
# L=TesterrorLsvm(mldata,index)
# cost=seq(25,75)/50
# Svm=data.frame(cost,R1,R2,R3,R4,R5,S1,S2,S3,S4,S5,L,P2,P3)

# colorgroup=numeric(51)
# costgroup=cost
# linegroup=c(numeric(255),numeric(255)+1,numeric(153)+2)
# for(i in 1:12){
#   colorgroup=c(colorgroup,numeric(51)+i)
#   costgroup=c(costgroup,cost)
# }
# valuegroup=c(R1,R2,R3,R4,R5,S1,S2,S3,S4,S5,L,P2,P3)
# Svm=data.frame(costgroup,colorgroup,linegroup,valuegroup)
# p=ggplot(Svm, aes(x=costgroup, y=valuegroup)) +
#   geom_line(aes(linetype=factor(linegroup), color=factor(colorgroup)))+
#   #geom_point(aes(color=sex))+
#    scale_colour_manual("",
#                            breaks = c("gamma=0.1 (radial)","gamma=0.6 (radial)", "gamma=1.1 (radial)", "gamma=1.6 (radial)", "gamma=2.1 (radial)","gamma=0.1 (sigmoid)","gamma=0.6 (sigmoid)", "gamma=1.1 (sigmoid)", "gamma=1.6 (sigmoid)", "gamma=2.1 (sigmoid)","linear","quadratic", "cubic"),
#             
#                                       values = c("red", "green", "blue", "orange","black","white", "wheat", "cyan", "brown","pink","greenyellow", "purple", "darkblue")) +
#   scale_linetype_manual("",
#                           breaks = c("gamma=0.1 (radial)","gamma=0.6 (radial)", "gamma=1.1 (radial)", "gamma=1.6 (radial)", "gamma=2.1 (radial)","gamma=0.1 (sigmoid)","gamma=0.6 (sigmoid)", "gamma=1.1 (sigmoid)", "gamma=1.6 (sigmoid)", "gamma=2.1 (sigmoid)","linear","quadratic", "cubic"),
#                           values = c("dotted", "dotted", "dotted", "dotted","dotted","dashed", "dashed", "dashed", "dashed","dashed","solid", "solid", "solid")) +
#   
#   
#   theme(legend.position="top")+scale_y_continuous("10CV error", limits = c(0.20,0.90))
# print(p)

# p=ggplot(data = Svm, aes(x = cost))+theme(text = element_text(size = 25))
# p=p+geom_line(aes(y = R1, colour = "gamma=0.1 (radial)",linetype="gamma=0.1 (radial)"))
# p=p+geom_line(aes(y = R2, colour = "gamma=0.6 (radial)",linetype = "gamma=0.6 (radial)"))
# p=p+geom_line(aes(y = R3, colour = "gamma=1.1 (radial)",linetype = "gamma=1.1 (radial)"))
# p=p+geom_line(aes(y = R4, colour = "gamma=1.6 (radial)",linetype = "gamma=1.6 (radial)"))
# p=p+geom_line(aes(y = R5, colour = "gamma=2.1 (radial)",linetype = "gamma=2.1 (radial)"))
# p=p+geom_line(aes(y = S1, colour = "gamma=0.1 (sigmoid)",linetype="gamma=0.1 (sigmoid)"))
# p=p+geom_line(aes(y = S2, colour = "gamma=0.6 (sigmoid)",linetype="gamma=0.6 (sigmoid)"))
# p=p+geom_line(aes(y = S3, colour = "gamma=1.1 (sigmoid)",linetype="gamma=1.1 (sigmoid)"))
# p=p+geom_line(aes(y = S4, colour = "gamma=1.6 (sigmoid)",linetype="gamma=1.6 (sigmoid)"))
# p=p+geom_line(aes(y = S5, colour = "gamma=2.1 (sigmoid)",linetype="gamma=2.1 (sigmoid)"))
# p=p+geom_line(aes(y = L, colour = "linear",linetype = "linear"))
# p=p+geom_line(aes(y = P2, colour = "quadratic",linetype = "quadratic"))
# p=p+geom_line(aes(y = P3, colour = "cubic",linetype = "cubic"))
# p=p+scale_colour_manual("",
#                         breaks = c("gamma=0.1 (radial)","gamma=0.6 (radial)", "gamma=1.1 (radial)", "gamma=1.6 (radial)", "gamma=2.1 (radial)","gamma=0.1 (sigmoid)","gamma=0.6 (sigmoid)", "gamma=1.1 (sigmoid)", "gamma=1.6 (sigmoid)", "gamma=2.1 (sigmoid)","linear","quadratic", "cubic"),
#                         values = c("red", "green", "blue", "orange","black","red", "green", "blue", "orange","black","greenyellow", "purple", "darkblue")) +
#   scale_linetype_manual("",
#                       breaks = c("gamma=0.1 (radial)","gamma=0.6 (radial)", "gamma=1.1 (radial)", "gamma=1.6 (radial)", "gamma=2.1 (radial)","gamma=0.1 (sigmoid)","gamma=0.6 (sigmoid)", "gamma=1.1 (sigmoid)", "gamma=1.6 (sigmoid)", "gamma=2.1 (sigmoid)","linear","quadratic", "cubic"),
#                       values = c("dotted", "dotted", "dotted", "dotted","dotted","dashed", "dashed", "dashed", "dashed","dashed","solid", "solid", "solid")) +
#   
#   xlab(" cost")
# p=p+scale_y_continuous("10CV error", limits = c(0.20,0.90))
# p=p+labs(title="Iterations of calculation of the variable cost in different SVM")
#  print(p)



  
  
  
  

# B=TesterrorBayes(mldata,index)
# k=c(1:50)
#  K=TesterrorKNN(mldata,index)
# 
# 
#  KNN=data.frame(k,K)
# 
#  p=ggplot(data = KNN, aes(x = k))+ theme(text = element_text(size = 25))                    # All font sizes
#  p=p+geom_line(aes(y = K, colour = "kNN"))
#  p=p+scale_colour_manual("",
#                          breaks = c("kNN"),
#                        values = c("red"))
# 
#   p=p+  xlab(" k")
# 
#  p=p+scale_y_continuous("10CV error", limits = c(0.35,0.9))
#  p=p+labs(title="Iterations of calculation of the variable k in kNN model")
#  print(p)

  baseline=c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36)
  predtrain=sample(mldatatrain$V1, size=length(mldatatrain$V1))
  print(sum(as.numeric(mldatatrain$V1!=predtrain))/length(mldatatrain$V1))
  predtest=sample(mldatatrain$V1, size=length(mldatatest$V1))
  print(sum(as.numeric(mldatatest$V1!=predtest))/length(mldatatest$V1))
  
  aucvtrain=numeric(30)
  classes=c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36)
  for (i in 1:30){ 
    roctrain=roc(as.numeric(mldatatrain$V1==classes[i]),as.numeric(predtrain==classes[i]))
    aucvtrain[i]=auc(roctrain)
  }
  auctrain=mean(aucvtrain)
print(auctrain)
  aucvtest=numeric(30)
  for (i in 1:30){ 
    roctest=roc(as.numeric(mldatatest$V1==classes[i]),as.numeric(predtest==classes[i]))
    aucvtest[i]=auc(roctest)
  }
  auctest=mean(aucvtest)
  print(auctest)