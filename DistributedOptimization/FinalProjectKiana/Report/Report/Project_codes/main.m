
%%
%%
clc
close all
tic
addpath(genpath('Graph_Creation'))
addpath(genpath('Figures'))
%% Parameters
%Network
numNode = 50;
compGraphNumEdge = numNode*(numNode-1)/2;
connectivityRatio = 0.01;   % if equal to 1 we will have a compelete graph
connectivityRatio = max([(numNode-1)/compGraphNumEdge, connectivityRatio]); 
numEdge = ceil(connectivityRatio*compGraphNumEdge);
treeFlag = 0;
branchFactor = 0;
if numEdge == numNode-1
    prompt = ['The Underlying Graph is a tree, Please enter the branch factor, it should be less than',num2str(numNode-1)];
    branchFactor = input(prompt);
    treeFlag = 1;
end
regularFlag = 1;
degree = 2;
if regularFlag == 1
    degree = ceil(2*numEdge/numNode);
    numEdge = degree*numNode/2;
end
connectivityRatio = numEdge/compGraphNumEdge;
%Local Objectives
numVariable = 3;
numObservation = 3;
noiseVariance = 1e-3;
%Simulation
numExperiment = 10;
coeff = [0.002 0.05 0.15 0.55 1 2.5 5 10];
numcoeff = length(coeff);
numIteration = 100;
errorNormalizedDist = zeros(numIteration,numcoeff,numExperiment);
errorNormalizedDecen = zeros(numIteration,numcoeff,numExperiment);
AvgDist = zeros(numIteration,numcoeff);
AvgDecen = zeros(numIteration,numcoeff);

%%

 %%%%Network Generation
[adjacencyMat] = networkGeneration(treeFlag,branchFactor,regularFlag,degree,numNode,numEdge);
   
 
%% Experiment Generation
for jj = 1: numExperiment
[x,observationVec,measurementMat,AA,BB] = experimetGeneraton(numNode,numVariable,numObservation,noiseVariance);
 %%% Ceneralized solution
xHatCen = inv(AA'*AA)*AA'*BB;

 %%% ADMM Algorithm
for ii = 1:length(coeff)
c = coeff(ii); %ADMMM Parameter        
%[errorNormalizedDist(:,ii,jj)] = ADMM_Dist(adjacencyMat,c,numNode,numVariable,numIteration,measurementMat,observationVec,xHatCen);
[errorNormalizedDecen(:,ii,jj)] = ADMM_Decen(c,numNode,numVariable,numIteration,measurementMat,observationVec,xHatCen);
end
end

for i = 1:numcoeff
   %AvgDist(:,i) = mean(errorNormalizedDist(:,i,:),3);
   AvgDecen(:,i) = mean(errorNormalizedDecen(:,i,:),3);
end
%semilogy(AvgDist);
%legend('c=0.002','c=0.05','c=0.15','c=0.55','c=1','c=2.5' , '5','c=10');
%figure();
semilogy(AvgDecen);
legend('c=0.002','c=0.05','c=0.15','c=0.55','c=1','c=5' ,'c=2.5','c=10');



%%%Comparing Decenterlized via Distributed
% for jj = 1: numExperiment
% [x,observationVec,measurementMat,AA,BB] = experimetGeneraton(numNode,numVariable,numObservation,noiseVariance);
%         %%% Ceneralized solution
% xHatCen = inv(AA'*AA)*AA'*BB;
%         %%% ADMM Algorithm
% 
% 
%  %ADMMM Parameter
% CDist=2.5;
% CDecen=10;
% [errorNormalizedDist(:,1,jj)] = ADMM_Dist(adjacencyMat,CDist,numNode,numVariable,numIteration,measurementMat,observationVec,xHatCen);
% [errorNormalizedDecen(:,1,jj)] = ADMM_Decen(CDecen,numNode,numVariable,numIteration,measurementMat,observationVec,xHatCen);
% 
% end
% 
% semilogy(mean(errorNormalizedDist(:,1,:),3));
% hold on;
% semilogy(mean(errorNormalizedDecen(:,1,:),3),'r');
  



toc




