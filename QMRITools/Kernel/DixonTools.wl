(* ::Package:: *)

(* ::Title:: *)
(*QMRITools DixonTools*)


(* ::Subtitle:: *)
(*Written by: Martijn Froeling, PhD*)
(*m.froeling@gmail.com*)


(* ::Section:: *)
(*Begin Package*)


BeginPackage["QMRITools`DixonTools`", Join[{"Developer`"}, Complement[QMRITools`$Contexts, {"QMRITools`DixonTools`"}]]];


(* ::Section:: *)
(*Usage Notes*)


(* ::Subsection:: *)
(*Functions*)


DixonToPercent::usage = 
"DixonToPercent[water, fat] converts the dixon water and fat data to percent maps.

Output is {waterFraction, fatFraction}.
The values of water and fat are arbitraty units and the ouput fractions are between 0 and 1."

DixonReconstruct::usage = 
"DixonReconstruct[real, imag, echo] reconstruxt Dixon data with initital guess b0 = 0 and T2star = 0.
DixonReconstruct[real, imag, echo, b0] reconstructs Dixon data with intitial guess T2star = 0.
DixonReconstruct[real, imag, echo, b0, t2] reconstructs Dixon data.

real is the real data in radials.
imag is the imaginary data in radians.
B0 can be estimated from two phase images using Unwrap.
T2 can be estimated from multiple echos using T2fit.

Output is {{watF,fatF},{watSig,fatSig},{inphase,outphase},{B0,T2star},itterations}.

The fractions are between 0 and 1, the B0 field map is in Hz and the T2start map is in ms.

DixonReconstruct[] is based on DOI: 10.1002/mrm.20624 and 10.1002/mrm.21737 (10.1002/nbm.3766)."


FixDixonFlips::usage = 
"FixDixonFlips[{mag, phase, real, imag}] checks if any volumes are 180 degrees out of phase and corrects them."


SimulateDixonSignal::usage = 
"SimulateDixonSignal[echo, fr, B0, T2] simulates an Dixon gradient echo sequence with echotimes.
Echotimes echo in ms, fat fraction fr between 0 and 1, field of resonance B0 in Hz and relaxation T2 in ms."

OptimizeDixonEcho::usage = 
"OptimizeDixonEcho[] shows a manipulate pannel which allos to optimize the dixon echos."


FindInPhaseEchos::usage = 
"FindInPhaseEchos[echos, iop] finds the two nearest echos to inphase which are best used for unwrapping using the iop time."

Unwrap::usage = 
"Unwrap[data] unwraps the given dataset. The data should be between -Pi and Pi. 
Unwrap[] is based on DOI: 10.1364/AO.46.006623 and 10.1364/AO.41.007437."

UnwrapSplit::usage = 
"UnwrapSplit[phase, data] unwarps the give phase dataset but splits the data into left and right using SplitData based in the data and performs the unwrapping seperately. The data should be between -Pi and Pi.
UnwrapSplit[] is based on DOI: 10.1364/AO.46.006623 and 10.1364/AO.41.007437."

UnwrapList::usage = 
"UnwrapList[list] unwraps a 1D list of values between -Pi and Pi."


(* ::Subsection::Closed:: *)
(*Options*)


DixonPrecessions::usage = 
"DixonPrecessions is an options for DixonReconstruct. Defines the rotation of the signal {-1,1} default is -1."

DixonFieldStrength::usage = 
"DixonFieldStrength is an options for DixonReconstruct. Defines the fieldstrengths in Tesla on which the data was acquired."

DixonFrequencies::usage = 
"DixonFrequencies is an options for DixonReconstruct. Defines the frequencies in ppm of the fat peaks being used."

DixonAmplitudes::usage = 
"DixonAmplitudes is an options for DixonReconstruct. Defines the relative amplitudes of the fat peaks being used."

DixonNucleus::usage = 
"DixonNucleus is an option for DixonReconstruct. Defines the nucleus for which the reconstruction is performed."

DixonTollerance::usage = 
"DixonTollerance is an options for DixonReconstruct. Defines at which change per itteration of b0 and R2star the ittarative methods stops. Default value is 0.1."

DixonMaskThreshhold::usage = 
"DixonMaskThreshhold is an options for DixonReconstruct. Defines at which threshhold the dixon reconstruction considers a voxel to be background noise. Defualt values is 0.05."

DixonFilterInput::usage = 
"DixonFilterInput is an options for DixonReconstruct. If True the input b0 and T2star values are smoothed using a gaussian kernel."

DixonFilterOutput::usage = 
"DixonFilterOutput is an options for DixonReconstruct. If True the out b0 and T2star values are smoothed Median filter and lowpassfiltering after which the water and fat maps are recomputed."


DixonFilterSize::usage = 
"DixonFilterSize is an options for DixonReconstruct. Defines the number of voxel with which the input b0 and T2star values are smoothed."

DixonIterations::usage = 
"DixonIterations is an options for DixonReconstruct. Defines the maximum itterations the fit can use."

DixonBipolar::usage = 
"DixonBipolar is an option for DixonReconstruct. If set to true it assumes alternating readout directions."

DixonClipFraction::usage =
"DixonClipFraction is an option for DixonReconstruct. If set true the fat fraction is clipped between 0 and 1."

DixonFilterType::usage = 
"DixonFilterType is an option for DixonReconstruct. FilterType can me \"Median\" or \"Laplacian\"."

MonitorUnwrap::usage = 
"MonitorUnwrap is an option for Unwrap. Monitor the unwrapping progress."

UnwrapDimension::usage = 
"UnwrapDimension is an option for Unwrap. Can be \"2D\" or \"3D\". 2D is for unwarpping 2D images or unwrapping the individual images from a 3D dataset \
(does not unwrap in the slice direction). 3D unwraps a 3D dataset in all dimensions."

UnwrapThresh::usage = 
"UnwrapThresh is an option for Unwrap. Is a value between 0.6 and 0.9, and defines when to unwrap, the higher the value the less unwrapping will be done."


(* ::Subsection::Closed:: *)
(*Error Messages*)


Unwrap::data2D = "Unwrapping Dimensions is 2D and this can only be preformed on 2D or 3D data. This data is `1`D."

Unwrap::data3D = "Unwrapping Dimensions is 3D and this can only be preformed on 3D data. This data is `1`D."

Unwrap::dim = "Unwrapping Dimensions can be \"2D\" or \"3D\", current value is `1`."


(* ::Section:: *)
(*Functions*)


Begin["`Private`"]


(* ::Subsection::Closed:: *)
(*DixonToPercent*)


SyntaxInformation[DixonToPercent] = {"ArgumentsPattern" -> {_, _}};

DixonToPercent[water_, fat_]:=DixonToPercent[water, fat, True]

DixonToPercent[water_, fat_, clip_?BooleanQ] := Block[{atot, fatMap, waterMap, fMask, wMask, afat, awater},
	afat = Abs[fat];
	awater = Abs[water];
	atot = Abs[fat + water];
	
	(*define water and fat maps*)
	waterMap = Chop[DevideNoZero[awater, atot, "Comp"]];
	fatMap = Chop[DevideNoZero[afat, atot, "Comp"]];
	
	(*noise bias correction*)
	wMask = Mask[waterMap, .5, MaskSmoothing->False];
	fMask = (1 - wMask) Mask[fatMap, .5, MaskSmoothing->False];
	
	If[clip,
		waterMap = Abs[wMask waterMap + (fMask - fMask fatMap)];
		fatMap = Abs[(wMask + fMask) - waterMap];
		waterMap = Abs[(wMask + fMask) - fatMap];
		Clip[{waterMap,fatMap},{0,1}]
		,
		waterMap = wMask waterMap + (fMask - fMask fatMap);
		fatMap = (wMask + fMask) - waterMap;
		waterMap = (wMask + fMask) - fatMap;
		Clip[{waterMap,fatMap},{-0.1,1.1},{-0.1,1.1}]
	]
]


(* ::Subsection:: *)
(*DixonReconstruct*)


(* ::Subsubsection::Closed:: *)
(*FixDixonFlips*)


SyntaxInformation[FixDixonFlips] = {"ArgumentsPattern" -> {{_, _, _, _}}};

FixDixonFlips[{mag_,phase_,real_,imag_}]:=Block[{p,r,i,c},
	p = FindComplexFlips[real,imag];
	{If[p==={},
		{mag,phase,real,imag}, 
		r = real;r[[All,p]]=-r[[All,p]];
		i = imag;i[[All,p]]=-i[[All,p]];
		Through[{Abs,Arg,Re,Im}[r+I i]]
	],p}
]


FindComplexFlips[real_,imag_]:=Block[{comp,diff,diffM,means},
	comp=real+I imag;
	diff=Differences[Transpose[comp]];
	diffM=Median@Abs@diff;
	means=MeanNoZero[Flatten[#]]&/@Abs[#-diffM&/@Abs[diff]];
	Flatten[Position[Partition[Boole[# > 2 Median[means] & /@ means], 2, 1], {1, 1}]] + 1
]


(* ::Subsubsection::Closed:: *)
(*DixonReconstruct*)


Options[DixonReconstruct] = {
	DixonPrecessions -> -1, 
	DixonFieldStrength -> 3, 
	DixonNucleus -> "1H",
	(*DixonFrequencies -> {{0}, {3.8, 3.4, 3.13, 2.67, 2.46, 1.92, 0.57, -0.60}},
	DixonAmplitudes -> {{1}, {0.089, 0.598, 0.047, 0.077, 0.052, 0.011, 0.035, 0.066}},*)
	DixonFrequencies -> {{0}, {3.8, 3.4, 3.1, 2.7, 2.5, 1.95, 0.5, -0.5, -0.6}},
	DixonAmplitudes -> {{1}, {0.088, 0.628, 0.059, 0.064, 0.059, 0.01, 0.039, 0.01, 0.042}},
	DixonIterations -> 20, 
	DixonTollerance -> 0.1, 
	DixonMaskThreshhold -> 0.1,
	DixonFilterInput -> True, 
	DixonFilterOutput -> True,
	DixonFilterSize -> 1,
	DixonFilterType -> "Median",
	DixonBipolar -> False,
	DixonClipFraction -> False,
	MonitorCalc -> False
	};


SyntaxInformation[DixonReconstruct] = {"ArgumentsPattern" -> {_, _, _, _., _., OptionsPattern[]}};

DixonReconstruct[real_, imag_, echo_, opts : OptionsPattern[]] := DixonReconstruct[real, imag, echo, 0, 0, opts]

DixonReconstruct[real_, imag_, echo_, b0i_, opts : OptionsPattern[]] := DixonReconstruct[real, imag, echo, b0i, 0, opts]

DixonReconstruct[real_, imag_, echo_, b0i_, t2i_, OptionsPattern[]] := Block[{
		necho, freqs, amps, eta, maxItt, thresh, filti, filto, filtFunc, mat, iop, Amat, Amati, ioAmat,
		complex, mask, range, zero, b0, r2, phi, phi0, result, cWat, cFat, phiEst, phi0Est, res, itt,
		fraction, signal, ioPhase, fit, t2, func, mon
	},
	
	(*algorithems are base on: *)	
	(*Triplett WT et.al. 10.1002/mrm.23917 - fat peaks*)
	(*Reeder et.al. 10.1002/mrm.20624 - iDEAL*)
	(*Huanzhou Yu et.al. 10.1002/jmri.21090 - iDEAL algorithm and T2* correction*)
	(*Bydder et.al. 10.1016/j.mri.2010.08.011 - initial phase*)
	(*Peterson et.al.10.1002/mrm.24657 - bipolar*)
	
	(*Byder et.al. 10.1016/j.mri.2011.07.004 - a matrix with bonds*)
	
	mon = OptionValue[MonitorCalc];
	
	(*metabolite frequencies and amplitudes*)
	freqs = OptionValue[DixonPrecessions] OptionValue[DixonFieldStrength] OptionValue[DixonFrequencies] GyromagneticRatio[OptionValue[DixonNucleus]];
	amps = #/Total[#] &/@ OptionValue[DixonAmplitudes];
	iop = {0, 0.5}/Abs[Total[(amps[[2]]^2) freqs[[2]]]/Total[amps[[2]]^2]];
	
	(*optimization settings*)
	eta = OptionValue[DixonTollerance];
	maxItt = OptionValue[DixonIterations];
	thresh = OptionValue[DixonMaskThreshhold];
	
	(*define filter*)
	filti = OptionValue[DixonFilterInput];
	filto = OptionValue[DixonFilterOutput];
	func = Switch[OptionValue[DixonFilterType],"Median", MedFilter, "Laplacian",LapFilter];
	filtFunc = func[#, OptionValue[DixonFilterSize]]&;

	(*get alternating readout signs for bipolar acquisition*)
	necho = Range@Length[echo];
	mat = If[OptionValue[DixonBipolar], Transpose[{echo, -(-1)^necho}], Transpose[{echo, (1)^necho}]];

	(*define the water fat matrixes*)
	Amat = (Total /@ (amps Exp[freqs (2 Pi I) #])) & /@ echo;
	Amati = Inverse[ConjugateTranspose[Amat] . Amat] . ConjugateTranspose[Amat];
	ioAmat = (Total /@ (amps Exp[freqs (2 Pi I) #])) & /@ iop;
			
	(*create complex data for fit*)
	If[mon, PrintTemporary["Prepairing data and field maps"]];
	complex = N[real + imag I];

	If[ArrayDepth[complex] === 4, complex = Transpose[complex]];
	mask = Closing[UnitStep[Abs[First@complex] - thresh], 1] Unitize[Total[Abs[complex]]];
	range = {0., 2 Max[Abs[complex]]};
	zero = 0. Re[First@complex];
	
	(*define complex field map and background phase*)
	b0 = mask If[b0i === 0, zero, If[filti, filtFunc[b0i], b0i]];
	r2 = DevideNoZero[1., t2i];	
	r2 = mask If[t2i === 0,  zero, If[filti, filtFunc[r2], r2]];
	phi0 =If[Length[echo]<3, 0, 0.25 Arg[DevideNoZero[complex[[2]]^2, (complex[[1]] complex[[3]]), "Comp"]]];
	phi0 = mask If[phi0 === 0,  zero, If[filti, filtFunc[phi0], phi0]];
	
	(*perform the dixon reconstruction*)
	complex = RotateDimensionsLeft@MaskData[complex, mask];
	phi = RotateDimensionsLeft@{(2 Pi b0 + I r2), phi0};
	If[mon, PrintTemporary["Performing dixon iDEAL reconstruction"]];
	result = DixonFitiC[complex, phi, mask, mat, Amat, Amati, eta, maxItt];
 	{cWat, cFat, phiEst ,phi0Est, res, itt} = RotateDimensionsRight[Chop[result]];

	(*filter the output*)
	If[filto,
		If[mon, PrintTemporary["Filtering field estimation and recalculating signal fractions"]];
		(*smooth b0 field and R2star maps*)
		phiEst = mask (filtFunc[Re[phiEst]] + DevideNoZero[1. ,filtFunc[Ramp[DevideNoZero[1., Im[phiEst]]]]] I);
		phi0Est = mask (filtFunc[Re[phi0Est]]);
		phi = RotateDimensionsLeft[{phiEst, phi0Est}];
		
		(*recalculate the water fat signals*)
		result = DixonFitiC2[complex, phi, mask, mat, Amat, Amati];
		{cWat, cFat, res} = RotateDimensionsRight[Chop[result]];
	];
	
	(*create the output*)
	If[mon, PrintTemporary["Generating all the needed outputs"]];
	itt = Round@Re@itt;
	mask = Times @@ (Mask[Abs[#], 2 range, MaskSmoothing -> False] & /@ {cWat, cFat});
	{cWat, cFat} = {mask cWat, mask cFat};
	fraction = DixonToPercent[cWat, cFat, OptionValue[DixonClipFraction]];

	(*signal and in/out phase data *)
	signal = 1000 Clip[Abs[{cWat, cFat}], range] / range[[2]];
	res = 1000 Clip[Abs[res], range] / range[[2]];
	ioPhase = 1000 Clip[RotateDimensionsRight[InOutPhase[cWat, cFat, ioAmat]], range]  / range[[2]];
	
	(*estimate b0 and t2star*)
	b0 = Re[phiEst]/(2 Pi);
	r2 = Im[phiEst];
	t2 = DevideNoZero[1, r2];
	fit = {
		Clip[b0, {-400., 400.}, {-400., 400.}], 
		Clip[t2, {0., 0.25}, {0., 0.25}],
		Clip[r2, {0., 1000.}, {0., 1000.}],
		phi0Est
	};
	
	(*give the output*)
	{fraction, signal, ioPhase, fit, itt, res}
]


InOutPhase = Compile[{{cWat, _Complex, 0}, {cFat, _Complex, 0}, {ioAmat, _Complex, 2}},
	Abs[ioAmat . {cWat, cFat}]
, RuntimeOptions -> "Speed", RuntimeAttributes -> {Listable}];


(* ::Subsubsection::Closed:: *)
(*DixonFit*)


DixonFitiC = Compile[{
		{ydat, _Complex, 1}, {phi, _Complex, 1}, {mask, _Real, 0},
		{mat,_Real,2}, {Amat, _Complex, 2}, {Amati, _Complex, 2}, 
		{eta, _Real, 0}, {maxItt, _Integer, 0}
	}, Block[{
		i, continue, phiEst, phi0Est, dPhi, dPhi0, res, rho, pMat, sigd, sol, B, Bi
	},
	If[mask > 0,
		(*initialize fit*)
		i = 0;
		continue = True;
		{phiEst, phi0Est} = phi;
		dPhi = dPhi0 = 0. I;
		res = rho = ydat 0.;
		
		(*perform itterative fitting*)
		While[continue,			
			(*update the field map*)
			phiEst += dPhi;
			phi0Est += Re@dPhi0;
			phi0Est = If[Abs[phi0Est] > 0.6, 0., phi0Est];
			
			(*define complex field map P(-phi) or (E D)^-1 *)
			pMat = Exp[-I mat . {phiEst, phi0Est}];
			
			(*demodulate the phase of the signal*)
			(*perform A.2 form 10.1002/jmri.21090, the water fat fraction*)
			(*A.rho is needed for Matrix B eq A.4 and eq A.5, calculat the fitted demodulated signal*)
			sigd = pMat ydat;
			rho = Amati . sigd;
			sol = Amat . rho;
			res = sigd - sol;
			
			(*Define the matrix B including bipolar 10.1002/mrm.24657 and initial phase*)
			(*Obtain the error terms eq A.5*)
			B = Join[I mat sol, Amat, 2];
			Bi = PseudoInverse[B][[1 ;; 2]];
			{dPhi, dPhi0} = Bi . res;
			
			(*chech for continue*)
			(*Re@deltaPhi = B0; 2Pi Im@deltaPhi = r2Star; Re@deltaPhi0 = phase errors;*)
			continue = !((Abs[Re@dPhi/(2 Pi)] < eta && Abs[Im@dPhi] < eta && Abs[100 Re@dPhi0] < eta) || i >= maxItt);
			i++;
		];
		(*output*)
		Join[rho, {phiEst, phi0Est, Sqrt[Mean[res^2]], i}],	ConstantArray[0., Length[Amat[[1]]] + 4]
	]
], RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed"]


DixonFitiC2 = Compile[{
	{ydat, _Complex, 1}, {phi, _Complex, 1}, {mask, _Real, 0},
	{mat, _Real, 2}, {Amat, _Complex, 2}, {Amati, _Complex, 2}}, 
	Block[{pMat, sigd, rho, res, rms, r1, r2},
		If[mask > 0,
			(*initialize values*)
			rho = res = ydat 0.;
			
			(*define complex field map P(-phi) or (E D)^-1, demodulate signal and find complex fraction*)
			pMat = Exp[-I mat . phi];
			sigd = pMat ydat;
			rho = Amati . sigd;
			
			(*calculate the residuals*)
			res = sigd - (Amat . rho);
						
			(*output*)
   			Join[rho, {Sqrt[Mean[res^2]]}],
   			ConstantArray[0., Length[Amat[[1]]] + 1]
		]
	]
, RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed"]


(* ::Subsection::Closed:: *)
(*SimulateDixonSignal*)


Clear[SimulateDixonSignal]

Options[SimulateDixonSignal] = {
	DixonNucleus -> "1H", 
	DixonPrecessions -> -1, 
	DixonFieldStrength -> 3, 
	DixonFrequencies -> {{0}, {3.8, 3.4, 3.13, 2.67, 2.46, 1.92, 0.57, -0.60}}, 
	DixonAmplitudes -> {{1}, {0.089, 0.598, 0.047, 0.077, 0.052, 0.011, 0.035, 0.066}}
}

SyntaxInformation[SimulateDixonSignal] = {"ArgumentsPattern" -> {_, _, _, _, OptionsPattern[]}};

SimulateDixonSignal[echo_, fr_, B0_, T2_, OptionsPattern[]] := Block[{precession,field,freqs,amps, Amat, phi, sig},
	precession = OptionValue[DixonPrecessions](*-1,1*);
	field = OptionValue[DixonFieldStrength];
	freqs = precession field GyromagneticRatio[OptionValue[DixonNucleus]] OptionValue[DixonFrequencies];
	amps = #/Total[#] & /@ OptionValue[DixonAmplitudes];
	
	Amat = (Total /@ (amps Exp[freqs (2 Pi I) #])) & /@ echo;
	phi = N@2 Pi B0 I - 1./T2;
	sig = Exp[phi echo] Amat;
	
	sig = sig . {fr, 1 - fr};
	{Re[sig], Im[sig]}
]


(* ::Subsection::Closed:: *)
(*OptimizeDixonEcho*)


SyntaxInformation[UnwrapList] = {"ArgumentsPattern" -> {}};

OptimizeDixonEcho[]:=Manipulate[
	fr=300/(field GyromagneticRatio["1H"]);
	echos=first+Range[0,necho-1]delta;
	pts=Transpose[Through[{Im,Re}[Exp[-2Pi echos/fr I]]]];
	e=FindInPhaseEchos[echos,fr,DixonBipolar -> bip];
	pre = Table[1/n -> Ceiling[n/2] fr/n, {n, 2, 7}];
	
	Column[{
		Switch[vis,
			"path",
			Show[
				Graphics[{Black,PointSize[.02],Point[pts]},PlotRange->{{-1.2,1.2},{-1.2,1.2}},AspectRatio->1,Axes->True,Ticks->None,ImageSize->300,PlotLabel->"Inphase echos for unwrapping: "<>ToString[e]],
				ListLinePlot[
					Table[Callout[pts[[i]], i, LabelStyle -> {FontSize -> 14, Bold}, CalloutStyle -> None], {i, Length[pts]}],
					PlotRange->{{-1.2,1.2},{-1.2,1.2}}, PlotStyle->Black, Mesh->All],
				Graphics[{{Green,PointSize[.04],Point@First@pts},{Red,PointSize[.04],Point@Last@pts}}],
					If[io,Graphics[{{PointSize[.02],Blue,Point[pts[[e]]]}}],Graphics[]]
			],
			"vectors",
			Show[
				Graphics[{Black,PointSize[.02],Point[pts]},PlotRange->{{-1.2,1.2},{-1.2,1.2}},AspectRatio->1,Axes->True,Ticks->None,ImageSize->300,PlotLabel->"Inphase echos for unwrapping: "<>ToString[e]],
				ListLinePlot[Table[Callout[pts[[i]], i, LabelStyle -> {FontSize -> 14, Bold}, CalloutStyle -> None], {i, Length[pts]}], PlotStyle -> Transparent,PlotRange->{{-1.2,1.2},{-1.2,1.2}}],
				Graphics[{{PointSize[.04],Green,Point@First@pts}}],
				Graphics[{{PointSize[.04],Red,Point@Last@pts}}],
				Graphics[{Thick,Arrow[{{0,0},#}&/@pts[[2;;-2]]]}],
				Graphics[{Thick,Green,Arrow[{{0,0},First@pts}]}],
				Graphics[{Thick,Red,Arrow[{{0,0},Last@pts}]}],
				If[io,Graphics[{Blue,Arrow[{{0,0},#}&/@pts[[e]]]}],Graphics[]],
				If[io,Graphics[{{PointSize[.02],Blue,Point[pts[[e]]]}}],Graphics[]]
			]
		],
		ListLinePlot[Transpose@pts, Mesh -> All, PlotStyle -> {Black, Gray}, ImageSize -> 300, Ticks -> None]
	}]
	,
	{{first,0.95(*fr*),"first echo"},0,2fr,0.005},
	{{delta,1.3,"echo spacing"},0.0,2fr,.005},
	{{delta, 1.3, "echo spacing"}, Table[Ceiling[n/2] fr/n -> 1/n, {n, 2, 7}], ControlType -> SetterBar},
	{{necho,10,"number of echos"},2,25,1},
	Delimiter,
	{{field,3,"field strength"},{1,1.5,3,7,9.4}},
	Delimiter,
	{{vis,"path","visualization"},{"path","vectors"}},
	Delimiter,
	{{io,False,"show inphase echos"},{True,False}},
	{{bip,False,"bipolar"},{True,False}},
	{fr,ControlType->None},
	{echos,ControlType->None},
	{pts,ControlType->None},
	{e,ControlType->None},
	ControlPlacement->Left,
	Initialization:>{
		field=3;
		fr=300/(field GyromagneticRatio["1H"])},
	SaveDefinitions->True
]


(* ::Subsection:: *)
(*Phase unwrap*)


(* ::Subsubsection::Closed:: *)
(*FindInPhaseEchos*)


Options[FindInPhaseEchos] = {DixonBipolar -> False}

SyntaxInformation[FindInPhaseEchos] = {"ArgumentsPattern" -> {_, _, OptionsPattern[]}};

FindInPhaseEchos[echos_, iop_, OptionsPattern[]]:=Block[{ord,phase},
	phase=If[#>0.5 ,#-1,#]&/@FractionalPart[echos/iop];
	ord=Flatten[Position[phase,#]&/@Nearest[phase,0,Length[phase]]];
	Sort[If[OptionValue[DixonBipolar],
		Select[ord,If[OddQ[First@ord],OddQ,EvenQ]][[1;;2]],
	ord[[;;2]]]]
]


(* ::Subsubsection::Closed:: *)
(*UnwrapList*)


SyntaxInformation[UnwrapList] = {"ArgumentsPattern" -> {_}};

UnwrapList[list_]:=Block[{jumps,lst,diff,out},
	lst=If[Head[First@list]===Complex,Arg@list,list]/Pi;
	diff=Differences[lst];
	jumps=2 Prepend[Accumulate[(-Sign[diff]) Round[Chop[Abs[diff],1.5]/2]],0];
	out=jumps+lst;
	Pi(Round[Subtract[Mean[list],Mean[out]],2]+out)
]


(* ::Subsubsection::Closed:: *)
(*Unwrap*)


Options[Unwrap]={MonitorUnwrap->True, UnwrapDimension->"2D", UnwrapThresh->0.5};

SyntaxInformation[Unwrap] = {"ArgumentsPattern" -> {_, OptionsPattern[]}};

(* Phase unwrapping algorithem based on M.A. Herraez et al 2002 and Abdul-Rahman 2007.
unwraping algorithem. Unwraps one image, needs functions: Diff, SecDiff, EdgeReliability and PairCoor*)

Unwrap[dat_,OptionsPattern[]]:= Block[{data, ind, undim, out, mon, thresh, len},
	undim = OptionValue[UnwrapDimension];
	mon = OptionValue[MonitorUnwrap];
	thresh = Clip[OptionValue[UnwrapThresh],{0.3, 0.9}];
	
	Switch[undim,
		
		"2D",
		data = N[dat];
		len = Length[data];
		Which[
			MatrixQ[data],
			If[mon,PrintTemporary["Unwrapping one image using 2D algorithm."]];
			out = Unwrapi[data, thresh];
			,
			ArrayQ[data,3],
			If[mon,PrintTemporary["Unwrapping ",Length[data]," images using 2D algorithm"]];
			Monitor[
				out = MapIndexed[( ind = First[#2]; Unwrapi[#1, thresh] )&, data, {ArrayDepth[data]-2} ];
				out = UnwrapZi[out, thresh];
			 ,If[mon,ProgressIndicator[ind, {0, len}],""]
			]
		];,
		
		"3D",
		data = N[ArrayPad[dat,1]];
		If[ArrayQ[data,3],
			If[mon,PrintTemporary["Unwrapping 3D data using 3D algorithm"]];
			out = ArrayPad[Unwrapi[data, thresh, mon],-1];
			,
			Message[Unwrap::data3D,ArrayDepth[data]]
			];,
		_,
		Message[Unwrap::dim,undim]
		];
		
	(*center around 0*)
	out
]


(* ::Subsubsection::Closed:: *)
(*UnwrapSplit*)


Options[UnwrapSplit] = Options[Unwrap]

SyntaxInformation[UnwrapSplit] = {"ArgumentsPattern" -> {_, _, OptionsPattern[]}};

UnwrapSplit[phase_, mag_,opts:OptionsPattern[]] := Block[{cutVal, phaseSplit, B0split},
	cutVal = CutData[mag][[3]];
	phaseSplit = CutData[phase, cutVal][[1 ;; 2]];
	B0split = Unwrap[#, opts] & /@ phaseSplit;
	StichData @@ B0split
]


(* ::Subsubsection::Closed:: *)
(*UnwrapZi*)


UnwrapZi[data_, thresh_]:= Block[{mask,slice,diff,meandiff,steps,off,unwrap,dat,num2,Roundi},
	
	Roundi = If[Negative[#], 
		num2=#-Ceiling[#]; If[-1<num2<-thresh,Floor[#],Ceiling[#]],
		num2=#-Floor[#]; If[1>num2>thresh,Ceiling[#],Floor[#]]
	]&;
	
	mask = Unitize[data];
	slice = Round[0.5Length[data]];
	diff = (#[[1]]-#[[2]]&/@ Partition[data/(2Pi),2,1]);
	
	meandiff = Median[#]&/@ Map[DeleteCases[Flatten[N[#]],0.]&,diff];
	steps = FoldList[Plus,0,Map[Roundi[#]&,meandiff]];
	off = Round[Median[DeleteCases[Flatten[N[data[[slice]]/(2Pi)]],0.]]];
	
	unwrap = steps-(steps[[slice]]+off);
	dat = (2Pi unwrap+data)mask//N;
	(dat - mask Round[MeanNoZero[Flatten[dat]],2Pi])
]


(* ::Subsubsection::Closed:: *)
(*Unwrapi*)


Unwrapi[dat_, thresh_] := Unwrapi[dat, thresh, False]

Unwrapi[dat_, thresh_, mon_] := Block[{data, mask, crp, dimi, sorted, groups, groupsize, groupnr, task},
	If[MinMax[N[dat]]==={0.,0.},
		dat,
		
		(*rescale the data to 2Pi = 1, makes it easyer to process*)
		data = dat / (2. Pi);
		dimi = Dimensions[data];
		
		(*remove zeros*)
		data = If[ArrayDepth[data] == 3, crp = FindCrop[data]; ApplyCrop[data, crp], data];
		
		(*make mask to pervent unwrapping in background*)
		mask = Mask[Ceiling[Abs@data], 1, MaskSmoothing ->False];
		
		(*Get the edges sotrted for reliability and precluster groups*)
		sorted = GetEdgeList[data, mask];
		{groups, groupsize} = MakeGroups[data, mask];
	
		(*make 2D data 3D and define shifts in add*)
		If[ArrayDepth[data] == 2,
			groups = {groups}; data = {data};
			sorted = Transpose[{#[[1]] + 1, 0 #[[1]] + 1, #[[2]], #[[3]]} &[Transpose[sorted]]];
		];
		
		(*Unwrap the data*)
		data = UnWrapC[sorted, data, groups, groupsize, thresh];
		
		(*make output in rad*)	
		If[ArrayDepth[dat] == 2, 
			(*output the 2D in rad*)
			2 Pi data[[1]],
			(*align to zero and ouput 3D in rad*)
			data = 2 Pi (data - mask Round[MeanNoZero[Flatten[data]]]);
			ReverseCrop[data, dimi, crp]
		]
	]
]


UnWrapC = Compile[{{sorted, _Integer, 2}, {datai, _Real, 3}, {groupsi, _Integer, 3}, {groupsizei, _Integer, 1}, {thresh,_Real,0}},
	Block[{data, const, dir, dim, groups, group1, group2, groupsize, groupnr, z1, z2, x1, x2, y1, y2, wrap, wrapT, pos, g1, g2, out, adds,add, diff},
		
		data = datai;
		groups = groupsi;
		groupsize = groupsizei;
		
		(*initialize parameters*)
		dim = Dimensions[data];
		groupnr = Length[groupsize];
		adds = {{1, 0, 0}, {0, 0, 1}, {0, 1, 0}};
		z1=x1=y1=z2=x2=y2=group1=group2=g1=g2=0;
		
		(*loop over all edges*)
		out = Map[(
			
			(*Get the voxel corrdinates and the neighbour, contrain to dimensions*)
			add = adds[[#[[1]]]];
			z1=#[[2]]; z2 = If[z1==dim[[1]], dim[[1]], z1+add[[1]]];
			x1=#[[3]]; x2 = If[x1==dim[[2]], dim[[2]], x1+add[[2]]];
			y1=#[[4]]; y2 = If[y1==dim[[3]], dim[[3]], y1+add[[3]]];
			        
			(*Get the group numbers*)
			group1 = groups[[z1, x1, y1]];
			group2 = groups[[z2, x2, y2]];
			
			(*Unwrapping logic*)
			(*0. Only process if both are not in background*)
			If[group1 > 0 && group2 > 0,
				
				(*1. Only process if both are not in same group or no group*)
				If[group1 != group2 || group1 == group2 == 1,
					
				(*Determine the wrap of the edge*)
				diff = data[[z1, x1, y1]] - data[[z2, x2, y2]];
				wrap = Sign[diff] Ceiling[Abs[diff] - thresh];
				wrapT = (wrap != 0);
				
				(*2. both already in a group*)
				If[group1 > 1 && group2 > 1,
					g1 = groupsize[[group1]];
					g2 = groupsize[[group2]];
					If[g1 >= g2,
						(*2A. group 1 is larger, add group 2 to group 1*)
						pos = BitXor[1, Unitize[groups - group2]];
						groups += ((group1 - group2) pos);
						groupsize[[group1]] = g1 + g2;
						groupsize[[group2]] = 0;
						If[wrapT, data += wrap pos];
						,
						(*2B. group 2 larger, add group 1 to group 2*)
						pos = BitXor[1, Unitize[groups - group1]];
						groups += ((group2 - group1) pos);
						groupsize[[group1]] = 0;
						groupsize[[group2]] = g1 + g2;
						If[wrapT, data -= wrap pos];
					],
					
					(*3. one of two pixels not in group*)
					Which[
						(*3A. only group 1 existst, add group 2 to group 1*)
						group1 > 1,
						groups[[z2, x2, y2]] = group1;
						groupsize[[group1]] += 1;
						If[wrapT, data[[z2, x2, y2]] += wrap];
						,
						(*3B. only group 2 existst, add group 1 to group 2*)
						group2 > 1,
						groups[[z1, x1, y1]] = group2;
						groupsize[[group2]] += 1;
						If[wrapT, data[[z1, x1, y1]] -= wrap];
						,
						(*3C. both belong to no group, make new group*)
						True,
						groupnr++;
						groups[[z1, x1, y1]] = groups[[z2, x2, y2]] = groupnr;
						AppendTo[groupsize,2];
						If[wrapT, data[[z2, x2, y2]] += wrap];
					]
				]
			]
		];
		(*close the map fucntion*)
		1) &, sorted];
		
	(*output the unwraped data*)
	data],
RuntimeOptions -> "Speed", Parallelization -> True];



(* ::Subsubsection::Closed:: *)
(*GetEdgeList*)


GetEdgeList[data_] := GetEdgeList[data, 1]

GetEdgeList[data_, maski_] := Block[{dep, diff, diff1, diff2, mask, edge, coor, fedge, ord, pos},
	dep = ArrayDepth[data];
	(*maske a mask if needed*)
	mask = If[maski === 1, Mask[Ceiling[Abs@data], 1, MaskSmoothing -> False], maski];
	
	(*calculate the second order diff*)
	{diff1, diff2} = Transpose[Partition[DiffU[ListConvolve[#, data, {2, -2}]] & /@ GetKernels[dep], 2]];
	diff = Total[(diff1 + diff2)^2];
	
	(*get the edge reliability*)
	edge = (RotateLeft[diff, #] + diff) & /@ Switch[dep, 2, {{0, 1}, {1, 0}}, 3, {{1, 0, 0}, {0, 0, 1}, {0, 1, 0}}];
	edge = MaskData[edge, mask];
	 
	(*sort the edges for reliability*)
	coor = MapIndexed[#2 &, edge, {dep + 1}];
	fedge = Flatten[edge, dep];
	ord = Ordering[fedge];
	pos = Position[Unitize[fedge[[ord]]], 1, 1, 1];
	pos=If[pos==={},1,pos[[1,1]]];
	
	Flatten[coor, dep][[ord]][[pos ;;]]
]


GetKernels[dep_] := Block[{ker, i, j, k, keri},
	Switch[dep,
		2,
		ker = ConstantArray[0, {3, 3}];
		ker[[2, 2]] = -1;
		({i, j} = #; keri = ker; keri[[i, j]] = 1; keri) & /@ {
			{2, 1}, {2, 3}, {1, 2}, {3, 2}, {1, 1}, {3, 3}, {1, 3}, {3, 1}
		}(*H,V,D1,D2*),
		3,
		ker = ConstantArray[0, {3, 3, 3}];
		ker[[2, 2, 2]] = -1;
		({i, j, k} = #; keri = ker; keri[[i, j, k]] = 1; keri) & /@ {
			{2, 1, 2}, {2, 3, 2}, {1, 2, 2}, {3, 2, 2}, {2, 2, 1}, {2, 2, 3},(*H,V,N*)
			{1, 1, 2}, {3, 3, 2}, {1, 3, 2}, {3, 1, 2},(*plane 1*)
			{1, 2, 1}, {3, 2, 3}, {1, 2, 3}, {3, 2, 1},(*plane 2*)
			{2, 1, 1}, {2, 3, 3}, {2, 1, 3}, {2, 3, 1},(*plane 3*)
			{1, 1, 1}, {3, 3, 3}, {1, 1, 3}, {3, 3, 1}, {1, 3, 1}, {3, 1, 3}, {3, 1, 1}, {1, 3, 3}(*diagonals*)
		}
	]
];


DiffU = Compile[{{diff, _Real, 0}}, 
	diff - Sign[diff] Ceiling[ Abs[diff] - 0.5]
, RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed"];


(* ::Subsubsection::Closed:: *)
(*MakeGroups*)


MakeGroups[data_] := MakeGroups[data, 1]

MakeGroups[data_, maski_]:=Block[{dep,dim,fun,min,max,part,dat,masks,small,nclus,clus,groupsize,groups,groupnr,mask},

	(*maske a mask if needed*)
	mask = If[maski === 1, Mask[Ceiling[Abs@data], 1, MaskSmoothing -> False], maski];
	dat = (mask data) - 2 (1 - mask);
		
	(*find mask ranges*)
	{min,max}=MinMax[data];
	part = {#[[1]] + 0.001, #[[2]] - 0.001} & /@ Partition[Range[-1, 1, 0.2] // N, 2, 1];
		
	(*make groups from masks*)
	clus = DeleteSmallComponents[MorphologicalComponents[
		Mask[dat, #, MaskSmoothing -> False], CornerNeighbors -> False], 
		If[ArrayDepth[data]===3, 15, 3], CornerNeighbors -> False] & /@ part;
		
	nclus = Prepend[Drop[Accumulate[Max /@ clus], -1], 0];
	groups = Total[MapThread[#2 Unitize[#1] + #1 &, {clus, nclus}]] + mask;
	
	(*create outputs, the size vector and group nrs*)
	groupsize = ConstantArray[0, Max[groups]];
	(groupsize[[#[[1]]]] = #[[2]]) & /@ Sort[Tally[Flatten[groups]]][[2 ;;]];
	{groups, groupsize}
]



(* ::Section:: *)
(*End Package*)


End[]

EndPackage[]
