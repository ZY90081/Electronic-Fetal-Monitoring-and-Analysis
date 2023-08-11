This folder contains all code for identifying uterine contractions from TOCO uterine activity signals. <br>
Reference: <br>



**Main.m**              -  Main code of 2-step uterine contraction identification <br>
**Eva_Derivative.m**   - Main code of derivative-based method <br>
**Eva_Threshold.m**    - Main code of threshold-based method <br>

**UA_quality.m** - compute qualities of uterine activity signals <br>

*Functions:* <br>
**contraction_detector_Threshold.m** - threshold-based method <br>
**contraction_detector_Derivative.m** - derivative-based method <br>
**contraction_detector_Template.m** - template matching method <br>
**contraction_detector_Energy.m** - energy detector  <br>
**contraction_detector_Diffoperator.m** - difference operator <br>
**contraction_detector_Diffoperator_Energy.m** - difference operator and energy detector <br>
**contraction_detector_classification.m** - test if candidate is a real contraction  <br>

**training_com_features.m** - 

**Fun_UApreprocessing.m**  - preprocess raw uterine activity signals <br>
**Fun_UApostprocessing.m** - postprocess after onset/offset detection <br>
**AsymmetricGamma.m** - generalized asymmetric Laplace distribution <br>
**Fun_fitAsymmetricGamma.m** - fit generalized asymmetric Laplace distribution model <br>
**onsetoffsetPair.m** - algorithm for pairing onsets and offsets from difference operator result  <br>
**optisolver.m** - estimation of parameters  <br>
**IOUsEdge.m** - compute Intersection over Union <br>
**PR_plot.m** - compute precision and recall <br>
**PlottingResults.m** - plot figures according all results  <br>
