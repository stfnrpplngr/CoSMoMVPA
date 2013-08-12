function predicted=cosmo_classify_svm(samples_train, targets_train, samples_test, opt)
% svm classifier wrapper (around svmtrain/svmclassify)
%
% predicted=cosmo_classify_svm(samples_train, targets_train, samples_test, opt)
%
% Inputs
% - samples_train      PxR training data for P samples and R features
% - targets_train      Px1 training data classes
% - samples_test       QxR test data
%-  opt                struct with options. supports any option that
%                      svmtrain supports 
%
% Output
% - predicted          Qx1 predicted data classes for samples_test
%
% See also svmtrain, svmclassify
%
% NNO Aug 2013