(* ::Package:: *)

(* ::Title:: *)
(*QMRITools DenoiseTools*)


(* ::Subtitle:: *)
(*Written by: Martijn Froeling, PhD*)
(*m.froeling@gmail.com*)


(* ::Section:: *)
(*Begin Package*)


BeginPackage["QMRITools`DenoiseTools`", Join[{"Developer`"}, Complement[QMRITools`$Contexts, {"QMRITools`DenoiseTools`"}]]];


(* ::Section:: *)
(*Usage Notes*)


(* ::Subsection::Closed:: *)
(*Functions*)


DeNoise::usage = 
"DeNoise[data,sigma,filtersize] removes Rician noise with standard deviation \"sigma\" from the given dataset using a kernel with size \"filtersize\" a gaussian kernel.
DeNoise[data,sigma,filtersize, Kernel->\"kerneltype\"] removes Rician noise with standard deviation \"sigma\" from the given dataset using a kernel with size \"filtersize\" and type \"kerneltype\".

Output is data denoised.

DeNoise[] is based on DOI: 10.1109/TMI.2008.920609."

PCADeNoise::usage = 
"PCADeNoise[data] removes rician noise from the data with PCA.
PCADeNoise[data, mask] removes rician noise from the data with PCA only withing the mask.
PCADeNoise[data, mask, sig] removes rician noise from the data with PCA only withing the mask using sig as prior knowledge or fixed value.

Output is de {data denoise, sigma map} by default if PCAOutput is Full then fitted {data dnoise , {sigma fit, average sigma}, {number components, number of fitted voxesl, number of max fits}, total fit -time per 500 ittt}.

PCADeNoise[] is based on DOI: 10.1016/j.neuroimage.2016.08.016 and 10.1002/mrm.26059."

NNDeNoise::usage = 
"NNDeNoise[data] removes rician noise from the data using self supravized neural net.
NNDeNoise[data, mask] removes rician noise from the data with PCA  using self supravized neural net withing the mask.

PCADeNoise[] is based on DOI:10.48550/arXiv.2011.01355."

DenoiseCSIdata::usage = 
"DenoiseCSIdata[spectra] perfroms PCA denoising of the complex values spectra, data has to be 3D and the spectral dimensions is last, {x,y,z,spectra}."

DenoiseDynamicSpectraData::usage = 
"DenoiseDynamicSpectraData[spectra] perfroms PCA denoising of the complex values spectra, The data is given as a list of dynamicly acquired spectra {dynamic ,spectra}."


AnisoFilterTensor::usage = 
"AnisoFilterTensor[tens, diffdata] Filter the tensor tens using an anisotropic diffusion filter (Perona-Malik). 
It uses the diffusion weighted data diffdata to find edges that are not visible in the tensor.
Edge weights based on the diffusion data are averaged over all normalized diffusion direction.

AnisoFilterTensor[tens] Same but does not use the data for edge identification.

Output is the smoothed tensor.

AnisoFilterTensor[] is based on DOI: 10.1109/ISBI.2006.1624856."

WeightMapCalc::usage =  
"WeightMapCalc[diffdata] calculates a weight map which is used in AnisoFilterTensor.

Output is a weight map of the diffdata which is high in isotropic regions and low at edges."


AnisoFilterData::usage = 
"AnisoFilterData[data] Filter the diffusion tensor data using an anisotropic filter based on the strucure tensor of the data. 

Output is the smoothed data.

AnisoFilterData[] is based on DOI: 10.1016/j.jbiomech.2021.110540 and 10.1016/j.mri.2009.10.001 and 10.1371/journal.pone.0126953."




(* ::Subsection::Closed:: *)
(*Options*)


DeNoiseKernel::usage = 
"DeNoiseKernel is and option for DeNoise. Values can be \"Disk\", \"Box\" or \"Gaussian\"."

DeNoiseMonitor::usage = 
"DeNoiseMonitor is and option for DeNoise. Monitor the denoising progres."

DeNoiseIterations::usage = 
"DeNoiseIterations is and option for DeNoise. Specifies the number of the denoising iterations."


PCAKernel::usage = 
"PCAKernel is an option of PCADeNoise. It sets the kernel size."

PCAOutput::usage = 
"PCAOutput is an option of PCADeNoise. If output is full the output is {datao, {output[[1]], sigmat}, {output[[2]], output[[3]], j}, timetot}.
Else the output is {datao, sigmat}."

PCATollerance::usage = 
"PCATollerance is an option of PCADeNoise and shuld be an integer > 0. Default value is 0. When increased the denoise method removes less noise."

PCAWeighting::usage = 
"PCAWeighting is an option of PCADeNoise and can be True of False. Default value is False. When True the weights of the per voxel result are calculated based on the number of non noise components."

PCAClipping::usage = 
"PCAClipping is an option of PCADeNoise and can be True of False. If True the output is clipped between 0 and the max absolute value of the input data."

PCANoiseSigma::usage = 
"PCANoiseSigma is an option of DenoiseCSIdata and can be \"Corners\" or \"Automatic\"."

PCAComplex::usage = 
"PCAComplex is an option of PCADeNoise and can be True of False. If set true the input data is expexted to be {real, imag}."


NNThreshhold::usage = 
"NNThreshhold is an options for NNDeNoise and specifies the automated back ground masking value."


AnisoStepTime::usage =
"AnisoStepTime is an option for AnisoFilterTensor and defines the diffusion time, when small more step are needed."

AnisoFilterSteps::usage =
"AnisoFilterSteps is an option for AnisoFilterTensor and defines the amoutn of diffusin steps taken. Higher is more smoothing."

AnisoWeightType::usage =
"AnisoWeightType is an option for AnisoFilterTensor and WeightMapCalc and defines the weighting, eigher 1, the exponent of (-g/kappa) or 2, 1/(1+g/kappa)."

AnisoKappa::usage =
"AnisoKappa is an option for AnisoFilterTensor and WeightMapCalc and defines the weighting strenght, all data is normalize to 100 before filetering."

AnisoItterations::usage = 
"AnisoItterations is an options for AnisoFilterData. It specifies the amount of denoising itterations."

AnisoKernel::usage = 
"AnisoKernel is an options for AnisoFilterData. It defines the kernel size."


(* ::Subsection::Closed:: *)
(*Error Messages*)


DeNoise::data =
"Error: not able to proces the combination of this data set (Dimensions `2` ) with the given size kernel `1`, posibilities:
- 2D data, 2D kernel, sigma = single value
- 3D data, 2D kernel, sigma = single value or list with value specified for each slice
- 3D data, 3D kernel, sigma = single value
- 4D data, 2D kernel, sigma = single value or 2D array with value specified for each slice and diffusion direction
- 4D data, 3D kernel, sigma = single value or list with value specified for each diffusion direction"

DeNoise::filt =
"Error: The dimension of the kernel (`1`D) is of higher order than the dimension of the dataset (`2`D)."

DeNoise::dim =
"Error: The dimension of the sigmap (`1`) is not the same as the dimension of the dataset (`2`)."

DeNoise::kern = 
"Error: Unknown kernel type:`1`, use \"Gaussian\", \"Box\" or \"Disk\"."

DeNoise::sig =
"Data and simga are of unequal dimensions. Data: `1`, Sigma: `2`."


(* ::Section:: *)
(*Functions*)


Begin["`Private`"]


(* ::Subsection:: *)
(*Denoise*)


(* ::Subsubsection::Closed:: *)
(*Denoise*)


Options[DeNoise] = {DeNoiseKernel -> "Gaussian", DeNoiseMonitor -> False, DeNoiseIterations -> 1};

SyntaxInformation[DeNoise] = {"ArgumentsPattern" -> {_, _, _, OptionsPattern[]}};

DeNoise[dat_, sigi_, filt_, OptionsPattern[]] := Module[{kern, out, type, dimsig, dimdat, data, sig},
	sig = N@sigi;
	data = ToPackedArray@N@dat;
	(*Check dimensions,must be of lower order than data*)
	If[ArrayQ[sig] && (ArrayDepth[data] == 3 || ArrayDepth[data] == 4),
		dimsig = Dimensions[sig];
		dimdat = Dimensions[data];
		If[(ArrayDepth[data] == 3 && dimsig != dimdat) || ArrayDepth[data] == 4 && dimsig != dimdat[[{1, 3, 4}]],
			Return[Message[DeNoise::dim, dimsig, dimdat]]
		];
	];
	
	(*Check dimensions,filter must be of lower order than data*)
	If[Length[filt] > ArrayDepth[data], Return[Message[DeNoise::filt, Length[filt], ArrayDepth[data]]]];
	
	(*Create filter*)
	kern = Switch[type = OptionValue[DeNoiseKernel],
		"Box", kern = BoxMatrix[filt]/Total[Flatten[BoxMatrix[filt]]],
		"Disk", kern = DiskMatrix[filt]/Total[Flatten[DiskMatrix[filt]]],
		"Gaussian", kern = GaussianMatrix[{filt}],
		_, Return[Message[DeNoise::kern, type]];
	];
	If[OptionValue[DeNoiseMonitor], PrintTemporary["Using " <> type <> " kernel."]];
	
	out = ToPackedArray@N@Nest[DeNoisei[#, sig, filt, kern] &, data, OptionValue[DeNoiseIterations]];
	If[
		ArrayQ[out], Return[Clip[out, {0.9 Min[data], 1.1 Max[data]}]],
		Return[Message[DeNoise::data, Dimensions[sig], Dimensions[data]]]
	]
]


(* ::Subsubsection::Closed:: *)
(*DeNoisei*)


(*Appling 2D kernel on 2D dataset*)
DeNoisei[data_?MatrixQ,sig_,filt_,kern_?MatrixQ]:=DeNoiseApp[data,sig,filt,kern]

(*Appling 3D kernel on 3D dataset*)
DeNoisei[data:{_?MatrixQ..},sig_,filt_,kern:{_?MatrixQ..}]:=DeNoiseApp[data,sig,filt,kern]

(*Appling 2D kernel on 3D dataset, Using one sigma value for all slices*)
DeNoisei[data:{_?MatrixQ..},sig_,filt_,kern_?MatrixQ]:=If[NumberQ[sig],
	Map[DeNoiseApp[#,sig,filt,kern]&,data],
	MapThread[DeNoiseApp[#1,#2,filt,kern]&,{data,sig}]
]

(*Appling 2D kernel on 4D dataset, Using one sigma value for all slices and directions.*)
DeNoisei[data:{{_?MatrixQ..}..},sig_,filt_,kern_?MatrixQ]:=If[NumberQ[sig],
	Map[DeNoiseApp[#,sig,filt,kern]&,data,{2}],
	Transpose[Map[MapThread[DeNoiseApp[#1,#2,filt,kern]&,{#,sig}]&,Transpose[data]]]
]

(*Appling 3D kernel on 4D dataset, Using one sigma value for all diffusion directions*)
DeNoisei[data:{{_?MatrixQ..}..},sig_,filt_,kern:{_?MatrixQ..}]:=Transpose[Map[DeNoiseApp[#1,sig,filt,kern]&,Transpose[data]]]


(* ::Subsubsection::Closed:: *)
(*DeNoiseApp*)


DeNoiseApp[data_, sig_, filt_, kern_] := Module[{secmod, quadmod},
	secmod = ListConvolve[kern, data^2, Transpose[{filt + 1, -(filt + 1)}], 0.];
	quadmod = ListConvolve[kern, data^4, Transpose[{filt + 1, -(filt + 1)}], 0.];
	If[NumberQ[sig],
		NoiseAppCN[secmod, quadmod, data, sig],
		NoiseAppC[secmod, quadmod, data, sig]
	]
]

NoiseAppCN = Compile[{{secmod, _Real, 2}, {quadmod, _Real, 2}, {data, _Real, 2}, {sig, _Real, 0}},
	Block[{top, div, K, deb},
		top = (4 sig^2 (secmod - sig^2));
		div = (quadmod - secmod^2) + 10^-10;
		K = (1 - top/div);
		deb = Sqrt[Clip[(secmod - 2 sig^2) + (K (data^2 - secmod)), {0., Infinity}]]
	]];

NoiseAppC = Compile[{{secmod, _Real, 2}, {quadmod, _Real, 2}, {data, _Real, 2}, {sig, _Real, 2}},
	Block[{top, div, K, deb},
		top = (4 sig^2 (secmod - sig^2));
		div = (quadmod - secmod^2) + 10^-10;
		K = (1 - top/div);
		deb = Sqrt[Clip[(secmod - 2 sig^2) + (K (data^2 - secmod)), {0., Infinity}]]
	]];

NoiseAppCN = Compile[{{secmod, _Real, 3}, {quadmod, _Real, 3}, {data, _Real, 3}, {sig, _Real, 0}},
	Block[{top, div, K, deb},
		top = (4 sig^2 (secmod - sig^2));
		div = (quadmod - secmod^2) + 10^-10;
		K = (1 - top/div);
		deb = Sqrt[Clip[(secmod - 2 sig^2) + (K (data^2 - secmod)), {0., Infinity}]]
	]];
    
NoiseAppC = Compile[{{secmod, _Real, 3}, {quadmod, _Real, 3}, {data, _Real, 3}, {sig, _Real, 3}},
	Block[{top, div, K, deb},
		top = (4 sig^2 (secmod - sig^2));
		div = (quadmod - secmod^2) + 10^-10;
		K = (1 - top/div);
		deb = Sqrt[Clip[(secmod - 2 sig^2) + (K (data^2 - secmod)), {0., Infinity}]]
	]];



(* ::Subsection:: *)
(*PCADenoise*)


(* ::Subsubsection::Closed:: *)
(*PCADeNoise*)


Options[PCADeNoise] = {
	PCAKernel -> 5, 
	PCAOutput -> False,
	PCATollerance -> 0, 
	PCAWeighting -> True, 
	PCAClipping -> True,
	PCAComplex->False,
	Method -> "Similarity",
	MonitorCalc -> False
};

SyntaxInformation[PCADeNoise] = {"ArgumentsPattern" -> {_, _., _., OptionsPattern[]}};

PCADeNoise[data_, opts : OptionsPattern[]] := PCADeNoise[data, 1, 0., opts];

PCADeNoise[data_, mask_, opts : OptionsPattern[]] := PCADeNoise[data, mask, 0., opts];

PCADeNoise[datai_, maski_, sigmai_, OptionsPattern[]] := Block[{
		wht, ker, tol, mon, data, min, max, maskd, mask, sigm, dim, zdim, ydim, xdim, ddim, 
		m, n, off, datao, weights, sigmat, start, sigmati, nmati, clip, comp, len,
		totalItt, output, j, sigi, zm, ym, xm, zp, yp, xp, fitdata, sigo, Nes, datn, 
		weight, posV, leng, nearPos, p, pi, pos, np
	},
	
	(*tollerane if>0 more noise components are kept*)
	{mon, wht, tol, ker, clip, comp} = OptionValue[{MonitorCalc, PCAWeighting, PCATollerance, PCAKernel, PCAClipping, PCAComplex}];
	
	(*concatinate complex data and make everything numerical to speed up*)
	data = ToPackedArray@N@If[comp, 
		clip = False;
		Join[datai[[1]], datai[[2]], 2], 
		datai
	];
	{min, max} = 1.1 MinMax[Abs[data]];
	maskd = Unitize@Total@Transpose[data];
	mask = ToPackedArray[N@(maski maskd)];
	sigm = ToPackedArray[N@sigmai];
		
	(*get data dimensions*)
	dim = {zdim, ddim, ydim, xdim} = Dimensions[data];
	
	(*define sigma*)
	sigm = If[NumberQ[sigm], ConstantArray[sigm, {zdim, ydim, xdim}], sigm];
	
	Switch[OptionValue[Method],
		(*--------------use similar signals--------------*)
		"Similarity",
		(*vectorize data*)
		{data, posV} = DataToVector[data, mask];
		sigm = First@DataToVector[sigm, mask];
		
		(*define runtime parameters*)
		m = Length[data[[1]]];
		n = Round[ker^3];
		
		(*parameters for monitor*)
		leng = Length[data];
		pos = Range@leng;

		(*ouput data*)
		datao = 0. data;
		weights = sigmat = sigmati = nmati = datao[[All, 1]];

		(*get positions of similar signals but in random batches such that nearest has speed*)
		np = 30000;
		np = Floor[leng/Floor[leng/np]];

		If[mon, PrintTemporary["Preparing data similarity"]];
		pos = If[leng <= 2 np, 
			{pos},
			SeedRandom[1234];
			pos = Partition[RandomSample[pos], np, np, 1, Nothing];
			If[Length[Last@pos]===np,
				pos,
				Append[pos[[;; -3]], Flatten[pos[[-2 ;;]], 1]]
			]
		];

		(*for each random batch find the nearest voxels and make pos array*)
		nearPos = Nearest[data[[#]] -> #, data[[#]], 2 n, 
			DistanceFunction -> EuclideanDistance, Method -> "Scan", 
			WorkingPrecision -> MachinePrecision] & /@ pos;
		nearPos = Flatten[Map[Prepend[RandomSample[Rest@#, n - 1], First@#] &, nearPos, {2}], 1];

		(*perform denoising*)
		j = 0;
		If[mon, PrintTemporary[ProgressIndicator[Dynamic[j], {0, leng}]]];
		{m, n} = MinMax[{m, n}];
		Map[(j++;
			
			p = #;
			pi = First@p;
	
			(*perform the fit and reconstruct the noise free data*)
			{sigo, Nes, datn} = PCADeNoiseFit[data[[p]], {m, n}, sigm[[pi]], tol];
			
			(*get the weightes*)
			weight = If[wht, 1./(m - Nes), 1.];
			
			(*sum data and sigma and weight for numer of components*)
			datao[[p]] += weight datn;
			sigmat[[p]] += weight sigo;
			weights[[p]] += weight;
			
			(*output sig, Nest and itterations*)
			sigmati[[pi]] = sigo;
			nmati[[pi]] = Nes;
		) &, nearPos];
		
		(*make everything in arrays*)
		datao = VectorToData[DevideNoZero[datao, weights], posV];
		sigmat = VectorToData[DevideNoZero[sigmat, weights], posV];
		output = {VectorToData[sigmati, posV], VectorToData[nmati, posV]};
		
		,
		(*--------------use patch---------------*)
		
		_,
		ker = If[EvenQ[ker], ker - 1, ker];
		
		(*prepare data*)
		data = RotateDimensionsLeft[Transpose[data]];
		
		(*define runtime parameters*)
		{m, n} = MinMax[{ddim, ker^3}];
		off = Round[(ker - 1)/2];
		
		(*ouput data*)
		datao = 0. data;
		weights = sigmat = datao[[All, All, All, 1]];
			
		(*parameters for monitor*)
		j = 0;
		start = off + 1;
		{zdim, ydim, xdim} = {zdim, ydim, xdim} - off;
		totalItt = Total[Flatten[mask[[start ;; zdim, start ;; ydim, start ;; xdim]]]];
		
		(*perform denoising*)
		If[mon, PrintTemporary[ProgressIndicator[Dynamic[j], {0, totalItt}]]];
		output = Table[
			(*Check if masked voxel*)
			If[mask[[z, y, x]] === 0.,
				{0., 0.}
				,
				j++;
				(*define initial sigma and get pixel range and data*)
				sigi = sigm[[z, y, x]];
				{{zm, ym, xm}, {zp, yp, xp}} = {{z, y, x} - off, {z, y, x} + off};
				fitdata = Flatten[data[[zm ;; zp, ym ;; yp, xm ;; xp]], 2];
				
				(*perform the fit and reconstruct the noise free data*)
				{sigo, Nes, datn} = PCADeNoiseFit[fitdata, {m, n}, sigi, tol];
				
				(*reshape the vector into kernel box and get the weightes*)
				datn = Fold[Partition, datn, {ker, ker}];
				weight = If[wht, 1./(m - Nes), 1.];
				
				(*sum data and sigma and weight for numer of components*)
				datao[[zm ;; zp, ym ;; yp, xm ;; xp, All]] += (weight datn);
				sigmat[[zm ;; zp, ym ;; yp, xm ;; xp]] += weight sigo;
				weights[[zm ;; zp, ym ;; yp, xm ;; xp]] += weight;
				
				(*output sig, Nest and itterations*)
				{sigo, Nes}
			], 
		{z, start, zdim}, {y, start, ydim}, {x, start, xdim}];

		(*make everything in arrays*)
		output = ArrayPad[#, off] & /@ RotateDimensionsRight[output];
		
		(*correct output data for weightings*)
		datao = Transpose@RotateDimensionsRight[Re@DevideNoZero[datao, weights]];
		sigmat = DevideNoZero[sigmat, weights];
	];
	
	(*define output, split it if data is complex*)
	datao = Which[
		comp, len = Round[Length[datao[[1]]]/2]; {datao[[All,1;;len]], datao[[All,len+1;;-1]]},
		clip, Clip[datao, {min, max}], 
		True, datao
	];

	If[OptionValue[PCAOutput],
		(*fitted dta,average sigma,{sigma fit,number components, number of fitted voxesl,number of max fits}*)
		{datao, sigmat, output},
		{datao, sigmat}
	]
]


(* ::Subsubsection::Closed:: *)
(*PCADeNoiseFit*)


(*internal function*)
PCADeNoiseFit[data_, {m_, n_}, sigi_?NumberQ, toli_] := Block[{
		trans, xmat, xmatT, val, mat, pi, sig, xmatN, tol, out
	},
	
	(*perform decomp*)
	trans = Subtract @@ Dimensions[data] > 0;
	{xmat, xmatT} = If[trans, {Transpose@data, data}, {data, Transpose@data}];
	{val, mat} = Reverse /@ Eigensystem[xmat . xmatT];

	(*if sigma is given perform with fixed sigma,else fit both*)
	{pi, sig} = GridSearch[Re[val], m, n, sigi];
	
	(*constartin pi plus tol*)
	tol = Round[Clip[pi - toli, {1, m}]];
	
	(*give output,simga,number of noise comp,and denoised matrix*)
	out = Transpose[mat[[tol ;;]]] . (mat[[tol ;;]] . xmat);
	{sig, tol, If[trans, Transpose@out, out]}
]


GridSearch = Compile[{{val, _Real, 1}, {m, _Integer, 0}, {n, _Integer, 0}, {sig, _Real, 0}}, Block[
	{valn, gam, sigq1, sigq2,p, pi},
	
	(*calculate all possible values for eq1 and eq2*)
	valn = val[[;; -2]]/n;
	p = Range[m - 1];
	gam = 4 Sqrt[N[p/(n - (m - (p + 1)))]];
	sigq1 = Accumulate[valn]/p;
	sigq2 = (valn - First[valn])/gam;
	
	(*find at which value eq1>eq2*)
	pi = If[sig === 0.,
		Total[1 - UnitStep[sigq2 - sigq1]],
		Total[1 - UnitStep[Mean[{sigq1, sigq2}] - sig^2]]
	];
	pi = If[pi <= 0, 1, pi];
	
	(*give output*)
	{pi, Sqrt[Ramp[(sigq1[[pi]] + sigq2[[pi]])/2]]}
], RuntimeOptions -> "Speed", Parallelization -> True];


(* ::Subsubsection::Closed:: *)
(*NNDeNoise*)


Options[NNDeNoise] = {NNThreshhold -> 2};

SyntaxInformation[NNDeNoise] = {"ArgumentsPattern" -> {_, _., _., OptionsPattern[]}};

NNDeNoise[data_, opts : OptionsPattern[]] := NNDeNoise[data, 1, opts];

NNDeNoise[data_, mask_, opts : OptionsPattern[]] := Block[{
		back, dat, coor, n, ran, dati, train, i
	},
	(*make selection mask and vectorize data*)
	back = Round[mask Mask[NormalizeMeanData[data], OptionValue[NNThreshhold]]];
	{dat, coor} = DataToVector[data, back];
	dat = ToPackedArray@N@dat;
	
	(*Get dimensions, training sample and define network*)
	n = Range@Length@First@dat;
	ran = 1.1 MinMax[dat];
	
	(*trian network per volume and generate denoised data*)
	(*DistributeDefinitions[dat, n];*)
	dat = Monitor[Table[
		train = Thread[(dati = dat[[All, Complement[n, {i}]]]) -> dat[[All, i]]];
		trained = Predict[train, ValidationSet -> RandomSample[train, Round[.1 Length[dat]]],
			Method -> {"LinearRegression", "OptimizationMethod" -> "StochasticGradientDescent","L2Regularization"->0.01},
			PerformanceGoal -> {"DirectTraining"},
			AnomalyDetector -> None, TrainingProgressReporting -> None, MissingValueSynthesis -> None
		];
		trained[dati]
	, {i, n}], ProgressIndicator[Dynamic[i], {0, Max[n]}]];
	
	ToPackedArray@N@Clip[Transpose[VectorToData[#, coor] & /@ dat], ran]
]


(* ::Subsubsection::Closed:: *)
(*DenoiseCSIdata*)


Options[DenoiseCSIdata] = {PCAKernel -> 5, PCANoiseSigma->"Corners"}

SyntaxInformation[DenoiseCSIdata]={"ArgumentsPattern"->{_, OptionsPattern[]}}

DenoiseCSIdata[spectra_, OptionsPattern[]] := Block[{sig, out, hist, len, spectraDen, nn ,sel},
	(* assusmes data is (x,y,z,spectra)*)
	len = Dimensions[spectra][[-1]];
	
	(*get the corner voxels to calcluate the noise standard deviation or automatic estimation*)

	sig = Switch[OptionValue[PCANoiseSigma],
		"Corners2",
		StandardDeviation[Flatten[spectra[[{1, -1}, {1, -1}, {1, -1}]]]],
		"Corners", 
		nn = Flatten[spectra[[{1, -1}, {1, -1}, {1, -1}]]];
		sel = FindOutliers[Re@nn, OutlierRange -> 5] FindOutliers[Im@nn, OutlierRange -> 5];
		nn = Pick[nn, sel, 1];
		StandardDeviation[nn]/Sqrt[2]
		,
		"Automatic", 0
	];
	
    (*Denoise the spectra data*)
    {spectraDen, sig} = PCADeNoise[Transpose[Join[Re@#, Im@#]]&[RotateDimensionsRight[spectra]], 1, sig, 
    	PCAClipping -> False, PCAKernel -> OptionValue[PCAKernel], MonitorCalc->False];
    
    Print[Mean@Flatten@sig];	
    	
    ToPackedArray@N@RotateDimensionsLeft[Transpose[spectraDen][[1 ;; len]] + Transpose[spectraDen][[len + 1 ;;]] I]
]


(* ::Subsubsection::Closed:: *)
(*DenoiseDynamicSpectraData*)


SyntaxInformation[DenoiseDynamicSpectraData]={"ArgumentsPattern"->{_}}

DenoiseDynamicSpectraData[spectra_] := Block[{len, data, sig, comp},
	(*merge Re and Im data*)
	len = Dimensions[spectra][[-1]];
	data = Join[Re@#, Im@#] &[Transpose[spectra]];
	
	(*perform denoising*)	
	{sig, comp, data} = PCADeNoiseFit[data, MinMax[Dimensions[data]], 0., 0];
	
	(*reconstruct complex spectra*)
	data = Transpose[data[[;;len]] + I data[[len+1;;]]];
	
	(*output data and sigma*)
	{ToPackedArray@N@data, sig}
]


(* ::Subsection:: *)
(*AnisotropicFilterTensor*)


(* ::Subsubsection::Closed:: *)
(*AnisotropicFilterTensor*)


Options[AnisoFilterTensor] = {AnisoWeightType->2, AnisoKappa->5., AnisoStepTime->1, AnisoFilterSteps->5};

SyntaxInformation[AnisoFilterTensor] = {"ArgumentsPattern" -> {_, _, OptionsPattern[]}};

AnisoFilterTensor[tensi_,opts:OptionsPattern[]]:=AnisoFilterTensor[tensi, 1, opts]

AnisoFilterTensor[tensi_,dat_,OptionsPattern[]]:=Block[{
	weights,kernels,mn,j,datf,kers,wts,lambda,finDiff,wtsI,
	itt,time,kappa,type, data, tens
	},
	(*get the options*)
	itt=OptionValue[AnisoFilterSteps];
	time=OptionValue[AnisoStepTime];
	kappa=N@OptionValue[AnisoKappa];
	type=Clip[Round@OptionValue[AnisoWeightType],{1,2}];
	
	(*calculate the edges based on the diffusion images*)
	weights = If[dat===1,
		1,
		PrintTemporary["Determaning the weights based on the data."];
		WeightMapCalc[ToPackedArray@N@dat, AnisoKappa->kappa, AnisoWeightType->type]
	];
	
	(*get the fixed parameters*)
	tens = ToPackedArray@N@tensi;
	mn = Mean[tens[[1;;3]]];
	{kers, wts} = KernelWeights[];
	lambda = 1/Length[kers];
	
	(*filter the tensor*)
	PrintTemporary["Anisotropic filtering of the tensor."];
	j=0;PrintTemporary[ProgressIndicator[Dynamic[j],{0,itt 6}]];
	Table[
		(*Normalize the diffusion tensor*)
		datf = 100 DevideNoZero[tens[[tt]],mn];
		(*perform the diffusion smoothing itterations*)
		Do[
			j++;
			finDiff = FinDiffCalc[datf,kers];
			wtsI = weights WeightCalc[finDiff,wts,kappa,type];
			datf = datf+time lambda Total@(wtsI finDiff);
			,itt
		];
		(*revert tensor normalization*)
		datf=mn datf/100
		(*loop over tensor*)
	,{tt,1,6}]
]


(* ::Subsubsection::Closed:: *)
(*WeightMapCalc*)


Options[WeightMapCalc]={AnisoWeightType->2, AnisoKappa->10.};

SyntaxInformation[WeightMapCalc] = {"ArgumentsPattern" -> {_,  OptionsPattern[]}};

WeightMapCalc[data_,OptionsPattern[]]:=Block[{
	kers,wts,weights,finDiff,dat,dim,len, kappa, type
	},
	(*get the options*)
	kappa=N@OptionValue[AnisoKappa];
	type=Clip[Round@OptionValue[AnisoWeightType],{1,2}];
	
	(*get the kernerl and weights*)
	{kers,wts}=KernelWeights[];
	
	(*prepare output *)
	dim=Dimensions[data];
	len=dim[[2]];dim=Drop[dim,{2}];
	weights=ConstantArray[0,Prepend[dim,Length[wts]]];
	
	(*get the weighting for all diffusion images*)
	i=0;PrintTemporary[ProgressIndicator[Dynamic[i],{0,len}]];
	(
		i++;
		(*normalize the data*)
		dat=100 #/Max[Abs[#]];
		(*add to the weights*)
		weights+=WeightCalc[FinDiffCalc[dat,kers],wts,kappa,type];
	)&/@Transpose[ToPackedArray@N@data];
	
	(*normalize the weights between 0 and 1*)
	(*weights=Mean[weights];
	weights=weights/Max[weights];*)
	(#/Max[#])&/@weights
]


(* ::Subsubsection::Closed:: *)
(*KernelWeights*)


KernelWeights[]:=Block[{cent,ker,keri,wtsi},
	ker=ConstantArray[0,{3,3,3}];
	ker[[2,2,2]]=-1;
	cent={2,2,2};
	Transpose[Flatten[Table[
	If[{i,j,k}==cent,
	Nothing,
	keri=ker;keri[[i,j,k]]=1;
	wtsi=N@Norm[cent-{i,j,k}];
	{keri,1/wtsi^2}
	],{i,1,3},{j,1,3},{k,1,3}],2]]
];


(* ::Subsubsection::Closed:: *)
(*WeightCalc*)


WeightCalc[finDiff_,wts_,kappa_,type_] := wts Switch[type,1,Exp[-((finDiff/kappa)^2)],2,1./(1.+(finDiff/kappa)^2)];


(* ::Subsubsection::Closed:: *)
(*FinDiffCalc*)


FinDiffCalc[dat_,kers_] := ParallelMap[ListConvolve[#,dat,{2,2,2},0]&,kers]


(* ::Subsection::Closed:: *)
(*AnisoFilterData*)


Options[AnisoFilterData] = {
	AnisoStepTime -> 1, 
	AnisoItterations -> 1, 
	AnisoKernel -> {0.25, 0.5}};

SyntaxInformation[AnisoFilterData] = {"ArgumentsPattern" -> {_, OptionsPattern[]}};

AnisoFilterData[data_, opts:OptionsPattern[]] := AnisoFilterData[data, {1, 1, 1}, opts]

AnisoFilterData[data_, vox_, opts:OptionsPattern[]] := Block[{
	dd, grads, k, jacTot, tMat, eval, evec, div, dati,
	sig, rho , step, itt, sc, max, tr, cr, ind
	},
	(*for implementation see 10.1002/mrm.20339*)
	
	(*crop background for speed*)
	{dati, cr} = AutoCropData[data];

	(*get the 4th dimensions on first place *)
	dati = ToPackedArray@N@Transpose[dati];
	max = Max[dati];
	tr = max/10000;
	ind = IdentityMatrix[3];
	sc = Max[vox]/vox;
	
	(*aniso filter kernel size *)
	{sig, rho} = OptionValue[AnisoKernel];
	step = OptionValue[AnisoStepTime];
	itt = OptionValue[AnisoItterations];
	
	Do[(*loop over itterrations*)
		(*get the data gradients*)
		grads = ToPackedArray@N[(
			dd = GaussianFilter[#, {1, sc sig}];
			sc (GaussianFilter[dd, 1, #1] & /@ ind)
		) & /@ dati];

		(*calculate the jacobian (aka structure tensor) and smooth it*)
		jacTot = ToPackedArray@N@TensMat[
			GaussianFilter[#, {1, sc rho}] & /@ Total[
				{#[[1]]^2, #[[2]]^2, #[[3]]^2, #[[1]] #[[2]], #[[1]] #[[3]], #[[2]] #[[3]]} &[Transpose[grads]]
			, {2}]
		];

		(*get the step matrix*)
		tMat = ToPackedArray@N@Map[If[Max[#] < tr, 
			{{0., 0., 0.}, {0., 0., 0.}, {0., 0., 0.}},
			{eval, evec} = Eigensystem[#];
			eval = eval = 1/(eval + 10.^-16);
			Transpose[evec] . DiagonalMatrix[3 eval/Total[eval]] . evec
		] &, jacTot, {3}];
		
		(*get the time step and calculate divergence of vector field*)
		div = Total[MapThread[GaussianFilter[#1, 1, #2] &, {#, ind}] & /@ 
			RotateDimensionsRight[DivDot[tMat, RotateDimensionsLeft[grads, 2]], 2], {2}];

		(*perform the smoothing step*)
		dati = ToPackedArray@N@Clip[dati + step div, {0, 2} max];
	, {itt}];
	
	(*output the data*)
	ReverseCrop[Transpose@dati, Dimensions@data, cr]
]


DivDot = Compile[{{t, _Real, 2}, {gr, _Real, 2}}, 
	gr . t, 
RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed"];


StrucTensCalc = Compile[{{eval, _Real, 1}, {evec, _Real, 2}, {tr, _Real, 0}},
	If[Max[eval] < tr, {{0., 0., 0.}, {0., 0., 0.}, {0., 0., 0.}},
		Transpose[evec] . DiagonalMatrix[3 eval/Total[eval]] . evec
], RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed"]


(* ::Section:: *)
(*End Package*)


End[]

EndPackage[]
