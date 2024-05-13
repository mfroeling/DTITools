(* ::Package:: *)

(* ::Title:: *)
(*QMRITools ReconstructionTools*)


(* ::Subtitle:: *)
(*Written by: Martijn Froeling, PhD*)
(*m.froeling@gmail.com*)


(* ::Section:: *)
(*Begin Package*)


BeginPackage["QMRITools`ReconstructionTools`", Join[{"Developer`"}, Complement[QMRITools`$Contexts, {"QMRITools`ReconstructionTools`"}]]];


(* ::Section:: *)
(*Usage Notes*)


(* ::Subsection::Closed:: *)
(*Functions*)


ReadListData::usage = 
"ReadListData[file] reads a list/data raw data file from the philips MR platform. The input file can either be .list or .data file.
Ouput is {{rawData, noise}, {head, types}}.
ReadListData[file, print] does the same but if print is set False no reporting is done."


MeanType::usage = 
"MeanType[kspace, types, type] calcualtes the Mean of the kspace data on type, where type is part of types. The kspace and types are generated by ReadListData.
MeanType[{kspace, types}, type] calcualtes the Mean of the kspace data on type, where type is part of types.
MeanType[kspace, types, {type,..}] calcualtes the Mean of the kspace data on each of the list type, where type is part of types.
Output is {kspace, types}."

TotalType::usage = 
"TotalType[kspace, types, type] calcualtes the Total of the kspace data on type, where type is part of types. The kspace and types are generated by ReadListData.
TotalType[{kspace, types}, type] calcualtes the Total of the kspace data on type, where type is part of types.
TotalType[kspace, types, {type,..}] calcualtes the Total of the kspace data on each of the list type, where type is part of types.
Output is {kspace, types}."

OrderKspace::usage = 
"OrderKspace[kspace, types, order] reorders the kspace data to order, where order is a list and each value is a part of types. The kspace and types are generated by ReadListData."

SagitalTranspose::usage = 
"SagitalTranspose[data] makes a transpose of the data of the second level ande reverses the slices."


FourierShift::usage = 
"FourierShift[data] shift the data to the right by half the data dimensions."

InverseFourierShift::usage = 
"InverseFourierShift[data] shift the data to the left by half the data dimensions."

ShiftedFourier::usage = 
"ShiftedFourier[kpace] performs a FourierTransform on the kspace and then shifts the data half the data dimensions."

ShiftedInverseFourier::usage = 
"ShiftedInverseFourier[data] shifts the data half the data dimensions and then performs a InverseFourierTransform on the data."

FourierShifted::usage = 
"FourierShifted[kspace] shifts the kspace half the kspace dimensions and then performs a FourierTransform on the kspace."

InverseFourierShifted::usage = 
"InverseFourierShifted[data] performs a InverseFourierTransform on the data and then shifts the kspace half the kspace dimensions."

FourierKspace2D::usage = 
"FourierKspace2D[kspace,head] performs a 2D reconstruction of 2D kspace data. Where kspace and head are generated by ReadListData."

FourierKspace3D::usage = 
"FourierKspace3D[kspace,head] performs a 3D reconstruction of 3D kspace data. Where kspace and head are generated by ReadListData."

FourierKspaceCSI::usage = 
"FourierKspaceCSI[kspace,head] performs a 3D reconstruction of 3D CSI kspace data. Where kspace and head are generated by ReadListData."


NoiseCorrelation::usage = 
"NoiseCorrelation[noise] calculates the noise correlation matrix, noise is {nrCoils, noise Samples}."

NoiseCovariance::usage = 
"NoiseCovariance[noise] calculates the noise covariance matrix, noise is {nrCoils, noise Samples}."


CoilCombine::usage = 
"CoilCombine[sig] combines the coil signals sig. Where sig is {nCoils, ...}.  
CoilCombine[sig, cov] combines the coil signals sig. Where sig is {nCoils, ...} and cov the complex noise correlation matrix.
CoilCombine[sig, cov, sens] combines the coil signals sig. Where sig is {nCoils, ...} and cov the complex noise correlation matrix and sense the coils sensitivitys.

Possible coil combination methods are \"Sum\", \"RootSumSqaures\", \"RoemerEqualNoise\", \"RoemerEqualSignal\", \"WSVD\".
RootSumSquares needs the signal. Can be performed with and without the noise covaricance matrix
RoemerEqualNoise needs the signal and the noise covaricance matrix. Can be performed with and without the sense data, without sense data the sensisity is estimated using the singal and the RSS reconstrucntion of the signa.
RoemerEqualSignal needs the signal and the noise covaricance matrix and the sense data.
WSVD needs the signal and the noise covariance matrix."

NormalizeSpectra::usage = 
"NormalizeSpectra[spec] normalizes spectra to be scaled to the max value of the absolute signal = 1000. Can be any dimension." 

MakeSense::usage = 
"MakeSense[coils, cov] makes a sense map for coils. Each coil signal is devided by the RSS reconstuction of the coils."


MakeHammingFilter::usage = 
"MakeHammingFilter[xdim] makes a 1D HammingKernel for filtering k-space.
MakeHammingFilter[{xdim}] makes a 1D HammingKernel for filtering k-space.
MakeHammingFilter[{xdim, ydim}] makes a 2D HammingKernel for filtering k-space in 2D CSI data of size {xdim, ydim}.
MakeHammingFilter[{xdim, ydim, zdim}] makes a 3D HammingKernel for filtering k-space in 3D CSI data of size {xdim, ydim, zdim}."

HammingFilterData::usage = 
"HammingFilterData[kspace] apllies a Hammingfilter to the data. The data is in immage space and can be 1D, 2D or 3D."

HammingFilterCSI::usage = 
"HammingFilterCSI[kspace] apllies a Hammingfilter to the k-space data. The data can be can be 1D, 2D or 3D, the spectral dimensions is the last dimensions (x,y,z, spectra)."


DeconvolveCSIdata::usage = 
"DeconvolveCSIdata[spectra] deconvolves the CSI spectra after HammingFilterCSI to revert the blurring of the hammingfiltering.
DeconvolveCSIdata[spectra, ham] deconvolves the CSI spectra with the acquired weighting ham to revert the blurring of the kspace weighting." 

FourierRescaleData::usage = 
"FourierRescaleData[data] rescales the data to double the dimensions using zeropadding in fourier space. 
FourierRescaleData[data, facotr] rescales the data to factor times the dimensions using zeropadding in fourier space."

CoilWeightedReconCSI::usage =
"CoilWeightedReconCSI[kspace, noise, head] performs reconstuction of raw 3DCSI data. The input kspace, noise and head are obtained using ReadListData.
The coil combination Methods can be \"Roemer\" or \"WSVD\"."

CoilWeightedRecon::usage =
"CoilWeightedRecon[kspace, noise, head] performs reconstuction of raw MS2D MRI data. The input kspace, noise and head are obtained using ReadListData.
The coil combination Methods can be \"Roemer\" or \"RSS\"."


(* ::Subsection::Closed:: *)
(*Options*)

WienerRegularization::usage =
"WienerRegularization is an option for DeconvolveCSIdata. It defines te amount of regularization used in the wiener deconvoltuion." 

DeconvolutionMethod::usage = 
"DeconvolutionMethod is an option for DeconvolveCSIdata. It specifies which deconvolution method to used."

HammingFilter::usage =
"HammingFilter is an option for CoilWeightedReconCSI. If True it applies a spatial hamming filter to the data." 

CoilSamples::usage = 
"CoilSamples is an option for CoilWeightedReconCSI and specifies how many fud samples are used to calcualte the coil sensitivity for Roemer reconstruction."

NormalizeOutputSpectra::usage = 
"NormalizeOutputSpectra is an option for CoilWeightedReconCSI."

AcquisitionMethod::usage = 
"AcquisitionMethod is an option for CoilWeightedReconCSI. Values can be \"Fid\" or \"Echo\"."

EchoShiftData::usage = 
"EchoShiftData is an option for CoilWeightedRecon."

OutputSense::usage = 
"OutputSense is an option for CoilWeightedRecon. If set true the function will also output the used Sense map."

RescaleRecon::usage = 
"RescaleRecon is an option for CoilWeightedRecon. If set true the data will be scaled to the range 0-1000."

SenseRescale::usage = 
"SenseRescale is an option for MakeSense. If set True the data is first downscaled by a factor 2 before making the sense map."

ReconFilter::usage = 
"ReconFilter is an option for CoilWeighted recon. If true the reconstruction gets a hamming filter."

(* ::Subsection:: *)
(*Error Messages*)


(* ::Section:: *)
(*Functions*)


Begin["`Private`"] 


(* ::Subsection::Closed:: *)
(*Read List Data*)


SyntaxInformation[ReadListData]={"ArgumentsPattern"->{_,_.}}

ReadListData[file_]:=ReadListData[file,True]

ReadListData[file_,print_]:=Block[{
	fl,head,list,data,lab,dataIndex,dataVals,dataValsN,ruleKx,ruleKy,ruleKz,ruleCoil,
	typ,pos,dataSplit,indexSplit, echo, scale, locs,cp,cn,cd,
	sizeInd,size,ind,off,noise,indData,nSamp,kspace,line,types,outData,outHead},
	
	fl=StringReplace[file,{".list"->"",".data"->""}];
	If[!FileExistsQ[fl<>".list"]||!FileExistsQ[fl<>".data"],Print["files not found"]];
	
	(*read the data - longest part*)
	list=ReadList[fl<>".list",String];
	data=BinaryReadList[fl<>".data","Complex64"];

	(*Get the header*)
	head=StringSplit/@Select[list,StringTake[#,1]==="."&];
	head = (p = Position[#, ":"][[1, 1]]; 
	     StringRiffle[#[[5 ;; (p - 1)]]] -> 
	      ToExpression[#[[(p + 1) ;;]]]) & /@ head;
	head[[All,2]]=If[Length[#]==1,#[[1]],#]&/@head[[All,2]];
	(*get the labels*)
	lab=StringSplit[list[[StringPosition[StringJoin[StringTake[#,1]&/@list],"# "][[1,1]]-2]]][[2;;-2]];
	
	(*parse text table*)
	dataIndex=Transpose[StringSplitExp[Select[list,StringTake[#,1]===" "&]]];(*longest part*)
	
	(*fix non matching noise and data coil numbers*)
	cp = Position[lab, "chan"][[1, 1]];
	{cn, cd} = {"NOI", "STD"} /. Thread[DeleteDuplicates[dataIndex[[1]]] -> (DeleteDuplicates[#[[All, 2]]] & /@ GatherBy[Transpose[{dataIndex[[1]], dataIndex[[cp]]}], First])];
	If[cn=!=cd,dataIndex[[cp]] = dataIndex[[cp]] /. Thread[cn -> cd]];
	
	(*create header values*)
	dataVals=Thread[lab->(Sort[DeleteDuplicates[#]]&/@dataIndex)];
	dataValsN=Thread["N_"<>#&/@dataVals[[All,1]]->Length/@dataVals[[All,2]] ];
	dataVals[[All, 2]] = If[Length[#] == 1, If[StringQ[#[[1]]], #, #[[1]]], #] & /@ dataVals[[All, 2]];
	
	(*Create rules for values that are not a normal range. eg kspace index or coil numbers*)
	If[MemberQ[lab,"kx"],ruleKx=Thread[("kx"/.dataVals)->(Range["N_kx"/.dataValsN]-1)]];
	ruleKy=Thread[("ky"/.dataVals)->(Range["N_ky"/.dataValsN]-1)];
	ruleKz=Thread[("kz"/.dataVals)->(Range["N_kz"/.dataValsN]-1)];
	ruleCoil=Thread[("chan"/.dataVals)->(Range["N_chan"/.dataValsN]-1)];
	
	(*partition raw data per k-line*)
	data=DynamicPartition[data,dataIndex[[-1]]/8];(*longest part*)
	
	(*split the data and index for data type*)
	typ=("typ"/.dataVals[[1]]);
	pos=Flatten@Position[dataIndex[[1]],#]&/@typ;
	dataSplit=Thread[typ->(data[[#]]&/@pos)];
	indexSplit=Thread[typ->(dataIndex[[All,#]]&/@pos)];
	
	(*get the number of sample in the data data*)
	nSamp=("STD"/.indexSplit)[[-1,1]]/8;
	AppendTo[dataValsN,"N_samp"->nSamp];
	
	(*get the data size*)
	sizeInd={"N_kx","N_ky","N_kz","N_chan","N_dyn","N_card","N_echo","N_loca","N_mix","N_extr1","N_extr2","N_aver","N_samp"};
	sizeInd=Select[sizeInd,MemberQ[dataValsN[[All,1]],#]&];
	size=sizeInd/.dataValsN;
	(*get the types with dimensions > 1*)
	types=Pick[sizeInd,Unitize[size-1],1];
	
	(*process noise data *)
	noise = "NOI"/.dataSplit;
	data = "STD"/.dataSplit;
	
	If[noise=!="NOI",
		scale = 1000/Max[Abs[noise]];
		noise = scale noise;
		,
		scale = 1000/Mean[Abs[Flatten[data]]];
		noise = 0.;
	];
		
	(*get acepterd sample data and index*)
	data = scale data;
	
	ind = sizeInd[[;;-2]]/.Thread["N_"<>#&/@lab->Range[Length[lab]]];
	indData = ("STD"/.indexSplit)[[ind]];
	
	(*reverse even echo*)
	echo = 1-Mod[indData[[Position[sizeInd,"N_echo"][[1,1]]]],2];
	data = MapThread[If[#2==0,Reverse@#,#]&,{data,echo}];
	
	(*convert the index values to array values*)
	off = If[MemberQ[lab,"kx"],1,0];
	If[MemberQ[lab,"kx"],indData[[1]]=indData[[1]]/.ruleKx;];
	indData[[1+off]] = indData[[1+off]]/.ruleKy;
	indData[[2+off]] = indData[[2+off]]/.ruleKz;
	indData[[3+off]] = indData[[3+off]]/.ruleCoil;
	indData=Transpose[indData+1];
	
	(*get the locations of non zero index*)
	locs = Flatten[Position[Unitize[size[[;; -2]] - 1], 1]];
	
	(*create squeezed k-space*)
	Clear[line];
	kspace = ToPackedArray@ReplacePart[ConstantArray[line, size[[locs]]], Thread[indData[[All, locs]] -> data]];(*longest part*)
	line = ConstantArray[0. + 0. I, nSamp];
	size = Dimensions[kspace];
	
	(*print output*)
	If[print,
		Print["Datatypes in data: ",("typ"/.dataVals[[1]])];
		Print[Column[Prepend[StringJoin/@Thread[{"  - ",types,": ",ToString/@size}],"The data contains: "]]];
	];
	
	Clear[data, indData];
	
	(*output*)
	{{ToPackedArray@kspace,noise},{Join[dataVals,dataValsN,head],types}}
]


(*split string en convert to expression*)
StringSplitExp[strings_]:=System`Convert`TableDump`ParseTable[StringCases[strings,Except[WhitespaceCharacter]..][[All,;;-2]],{{"",""},{"-","+"},"."},False]


(* ::Subsection:: *)
(*Raw Data manipulation*)


(* ::Subsubsection::Closed:: *)
(*Mean over type*)


SyntaxInformation[MeanType]={"ArgumentsPattern"->{_,_,_.}}

(*Mean over list of values*)
MeanType[list_,type_,posS_List]:=Fold[MeanType,{list,type},posS]
(*Mean such that output and input match*)
MeanType[{list_,type_},posS_String]:=MeanType[list,type,posS]
(*single evaluation of mean*)
MeanType[list_,type_,posS_String]:=Block[{pos},
	(*Print[type];*)
	pos=posS/.Thread[type->Range[Length[type]]];
	(*Print["mean over: ",posS," (",pos")"];*)
	If[IntegerQ[pos],{MeanAt[list,pos],Drop[type,{pos}]},$Failed]
]


(* ::Subsubsection::Closed:: *)
(*Total over type*)


SyntaxInformation[TotalType]={"ArgumentsPattern"->{_,_,_.}}

(*Mean over list of values*)
TotalType[list_,type_,posS_List]:=Fold[TotalType,{list,type},posS]
(*Mean such that output and input match*)
TotalType[{list_,type_},posS_String]:=TotalType[list,type,posS]
(*single evaluation of mean*)
TotalType[list_,type_,posS_String]:=Block[{pos},
	(*Print[type];*)
	pos=posS/.Thread[type->Range[Length[type]]];
	(*Print["mean over: ",posS," (",pos")"];*)
	If[IntegerQ[pos],{TotalAt[list,pos],Drop[type,{pos}]},$Failed]
]


(* ::Subsection::Closed:: *)
(*MeanAt*)


SyntaxInformation[MeanAt]={"ArgumentsPattern"->{_,_}}

(*calculate mean at specific level*)
MeanAt[list_,level_]:=Block[{tot,wgth},
	tot = Total[list, {level}];
	wgth= Total[Unitize[Abs[list]],{level}];
	ToPackedArray[DevideNoZero[Re@tot, wgth, "Comp"] + I DevideNoZero[Im@tot, wgth, "Comp"]]
]


(* ::Subsection::Closed:: *)
(*TotalAt*)


SyntaxInformation[TotalAt]={"ArgumentsPattern"->{_,_}}

(*calculate mean at specific level*)
TotalAt[list_,level_]:=ToPackedArray@Total[list,{level}]/;1<=Abs[level]<=ArrayDepth@list


(* ::Subsubsection::Closed:: *)
(*Order K-space*)


SyntaxInformation[OrderKspace]={"ArgumentsPattern"->{_,_,_.}}

(*put kspace in requested order*)
OrderKspace[kspace_,type_,order_]:=OrderKspace[{kspace,type},order]
OrderKspace[{kspace_,type_},order_]:=Block[{mis,sel,typeOut},
mis=If[!MemberQ[type,#],#,Nothing]&/@order;
	If[mis=!={},
		Print["the types ",mis," are missing"]
		,		
		sel = If[MemberQ[order, #], 1, 0] & /@ type;
		typeOut = Pick[type, sel, 1];
		sel = All sel + 1 - sel;
		{ToPackedArray[Transpose[(kspace[[##]] & @@ sel), Flatten[(Position[order, #1] &) /@ typeOut]]], order}		
	]
]


(* ::Subsubsection::Closed:: *)
(*Sagittal Transpose*)


SyntaxInformation[SagitalTranspose]={"ArgumentsPattern"->{_}}

SagitalTranspose[data_]:=(Reverse[Transpose[#1],2]&)/@data;


(* ::Subsection:: *)
(*Fourier Functions*)


(* ::Subsubsection::Closed:: *)
(*FourierShift*)


SyntaxInformation[FourierShift]={"ArgumentsPattern"->{_}}

FourierShift[data_]:=RotateRight[data, Floor[Dimensions[data]/2]];


(* ::Subsubsection::Closed:: *)
(*FourierShift*)


SyntaxInformation[InverseFourierShift]={"ArgumentsPattern"->{_}}

InverseFourierShift[data_]:=RotateLeft[data,Floor[Dimensions[data]/2]];


(* ::Subsubsection::Closed:: *)
(*Fourier Functions*)


SyntaxInformation[ShiftedFourier]={"ArgumentsPattern"->{_,_.}}

ShiftedFourier[time_] := FourierShift[Fourier[time,FourierParameters->{-1,1}]];

ShiftedFourier[time_,"Fid"] := FourierShift[Fourier[time,FourierParameters->{-1,1}]];

ShiftedFourier[time_,"Echo"] := FourierShift[Fourier[FourierShift[time],FourierParameters->{-1,1}]];


SyntaxInformation[ShiftedInverseFourier]={"ArgumentsPattern"->{_,_.}}

ShiftedInverseFourier[spec_] := InverseFourier[InverseFourierShift[spec],FourierParameters->{-1,1}];

ShiftedInverseFourier[spec_,"Fid"] := InverseFourier[InverseFourierShift[spec],FourierParameters->{-1,1}];

ShiftedInverseFourier[spec_,"Echo"] := FourierShift[InverseFourier[InverseFourierShift[spec],FourierParameters->{-1,1}]];


SyntaxInformation[FourierShifted]={"ArgumentsPattern"->{_}}

FourierShifted[time_] := Fourier[FourierShift[time],FourierParameters->{-1,1}];


SyntaxInformation[InverseFourierShifted]={"ArgumentsPattern"->{_}}

InverseFourierShifted[spec_] := InverseFourierShift[InverseFourier[spec,FourierParameters->{-1,1}]];


(* ::Subsubsection::Closed:: *)
(*FourierKspace2D*)


SyntaxInformation[FourierKspace2D] = {"ArgumentsPattern" -> {_, _, _.}};

FourierKspace2D[kspace_, head_, filt_:False] := Block[{ksize, data, kspacef, dim, over, kfull, ksPad, shift, clip, ham},
	(*the acquired k-space size*)
	ksize = {"N_ky", "N_samp"} /. head;
	(*get the final target data dimensions*)
	dim = {"Y-resolution", "X-resolution"} /. head;
	(*the amount of oversampling performed*)
	over = {"ky_oversample_factor", "kx_oversample_factor"} /. head;
	(*get the image padding and image shift*)
	shift = Round[Total[#] & /@ ({"Y_range", "X_range"} /. head)/2];
	
	(*to what size to pad the images*)
	kfull = Round[dim over];
	(*padding after zero filling and fourier*)
	ksPad = Transpose[{Floor[#], Ceiling[#]} &[(kfull - ksize)/2]];
	(*the amount of data that needs to be removed to come to correct dimensions*)
	clip = Transpose[{Floor[#] + 1, -Ceiling[#] - 1} &[(kfull - dim)/2]];
	
	(*Reconstruct and Hammingfilter the data if needed*)
	kspacef = If[filt === "Raw", Map[MakeHammingFilter[Dimensions[#]]#&, kspace, {-2}], kspace];
	data = FourierKspace2DI[kspacef, ksPad, shift, clip];
	ToPackedArray@If[filt === True, Map[HammingFilterData, data, {-2}], data]
]

FourierKspace2DI = Compile[{{data, _Complex, 2}, {ksPad, _Integer, 2}, {shift, _Real, 1}, {clip, _Integer, 2}},
	Block[{dat},
		(*pad the data to the full range*)
		dat = ArrayPad[data, ksPad];
		(*perform the 2D Fourier*)
		dat = FourierShifted[dat];
		dat = FourierShift[dat];
		(*perform the correction for the k-space range*)
		dat = RotateRight[dat, shift];
		(*clip the data to the correct dimensions*)
		Chop[dat[[clip[[1, 1]] ;; clip[[1, 2]], clip[[2, 1]] ;; clip[[2, 2]]]]]
	], 
RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed"];


(* ::Subsubsection::Closed:: *)
(*FourierKspace3D*)


SyntaxInformation[FourierKspace3D] = {"ArgumentsPattern" -> {_, _, _.}};

FourierKspace3D[kspace_, head_, filt_:False] := Block[{ksize, kspacef, dim, over, kfull, ksPad, shift, clip, data},
	(*the acquired k-space size*)
	ksize = {"N_kz", "N_ky", "N_samp"} /. head;
	(*get the final target data dimensions*)
	dim = {"Z-resolution", "Y-resolution", "X-resolution"} /. head;
	(*the amount of oversampling performed*)
	over = {"kz_oversample_factor", "ky_oversample_factor", "kx_oversample_factor"} /. head;
	(*get the image padding and image shift*)
	shift = Round[Total[#] & /@ ({"Z_range", "Y_range", "X_range"} /. head)];
	
	(*to what size to pad the images*)
	kfull = Round[dim over];
	(*padding after zero filling and fourier*)
	ksPad = Transpose[{Floor[#], Ceiling[#]} &[(kfull - ksize)/2]];
	(*the amount of data that needs to be removed to come to correct dimensions*)
	clip = Transpose[{Floor[#] + 1, -Ceiling[#] - 1} &[(kfull - dim)/2]];

	(*Reconstruct and Hammingfilter the data if needed*)
	kspacef = If[filt === "Raw", Map[MakeHammingFilter[Dimensions[#]]#&, kspace, {-3}], kspace];
	data = FourierKspace3DI[kspacef, ksPad, shift, clip];
	If[filt === True, Map[HammingFilterData, data, {-3}], data]
  ]

FourierKspace3DI = Compile[{{data, _Complex, 3}, {ksPad, _Integer, 2}, {shift, _Integer, 1}, {clip, _Integer, 2}},
	Block[{dat},
		dat = data;
		(*pad the data to the full range*)
		dat = ArrayPad[dat, ksPad];
		(*perform the 3D Fourier*)
		dat = FourierShifted[dat];
		dat = Map[FourierShift, dat, {-2}];
		(*perform the correction for the k-space range*)
		dat = RotateRight[dat, shift];
		(*clip the data to the correct dimensions*)
		Chop[dat[[clip[[1, 1]] ;; clip[[1, 2]], clip[[2, 1]] ;; clip[[2, 2]], clip[[3, 1]] ;; clip[[3, 2]]]]]
	], 
RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed"];


(* ::Subsubsection::Closed:: *)
(*FourierKspaceCSI*)


SyntaxInformation[FourierKspaceCSI] = {"ArgumentsPattern" -> {_, _, _.}}

FourierKspaceCSI[kspace_, head_]:= FourierKspaceCSI[kspace, head, "3D"]

FourierKspaceCSI[kspace_, head_, "3D"]:=Block[{ksPad,dim,imPad,shift,kspaceP,imData},
	(*get the oversampling padding*)
	ksPad = Round[({"Z-resolution","Y-resolution","X-resolution"}{"kz_oversample_factor","ky_oversample_factor","kx_oversample_factor"}-{"N_kz","N_ky","N_kx"})/2/.head];
	(*get the final data dimentions*)
	dim = {"Z-resolution","Y-resolution","X-resolution"}/.head;
	(*pad the kaspaces with zeros*)
	kspaceP = ArrayPad[#,Transpose@{ksPad,ksPad},0.+0.I]&/@kspace;
	(*get the image padding and image shift*)
	shift = Total[#]&/@({"Z_range","Y_range","X_range"}/.head);
	(*perform the fourie transform*)
	imData = RotateRight[FourierShift[FourierShifted[#]],shift]&/@kspaceP
]

FourierKspaceCSI[kspace_, head_, "2D"]:=Block[{ksPad,dim,imPad,shift,kspaceP,imData},
	(*get the oversampling padding*)
	ksPad = Round[({"Y-resolution","X-resolution"}{"ky_oversample_factor","kx_oversample_factor"}-{"N_ky","N_kx"})/2/.head];
	(*get the final data dimentions*)
	dim = {"Y-resolution","X-resolution"}/.head;
	(*pad the kaspaces with zeros*)
	kspaceP = ArrayPad[#,Transpose@{ksPad,ksPad},0.+0.I]&/@kspace;
	(*get the image padding and image shift*)
	shift = Total[#]&/@({"Y_range","X_range"}/.head);
	(*perform the fourie transform*)
	imData = RotateRight[FourierShift[FourierShifted[#]],shift]&/@kspaceP
]


(* ::Subsection::Closed:: *)
(*NoiseCorrelation*)


SyntaxInformation[NoiseCorrelation]={"ArgumentsPattern" -> {_}}

NoiseCorrelation[noise_] := Correlation[Transpose[noise]]


(* ::Subsection::Closed:: *)
(*NoiseCovariance*)


SyntaxInformation[NoiseCovariance]={"ArgumentsPattern" -> {_}}

NoiseCovariance[noise_] := Covariance[Transpose[noise]]


(* ::Subsection:: *)
(*CoilCombine*)


(* ::Subsubsection::Closed:: *)
(*CoilCombine*)


Options[CoilCombine] = {Method -> "RoemerEqualNoise", SenseRescale -> False};

SyntaxInformation[CoilCombine] = {"ArgumentsPattern" -> {_, _., _., OptionsPattern[]}};

CoilCombine[sig_, opts : OptionsPattern[]] := CoilCombine[sig, 1, 1, opts]

CoilCombine[sig_, cov_, opts : OptionsPattern[]] := CoilCombine[sig, cov, 1, opts]

CoilCombine[sig_, cov_, sen_, OptionsPattern[]] := Block[{met, weight, sigt, sent, covi, rec},
	met = OptionValue[Method];
	
	(*prewighten noise if snr recon*)
	weight = If[StringTake[met, -3] === "SNR", CovToWeight[cov], IdentityMatrix[Length[sig]]];
	
	(*put ncoils as last dimensions signal*)
	sigt = If[ArrayDepth[sig] > 1,
		If[met === "WSVD",
			If[ArrayDepth[sig] == 2, sig, RotateDimensionsLeft[Transpose[sig], 2]],
			RotateDimensionsLeft[weight.sig]
		], weight.sig
	];
	
	(*inverse noise cov*)
	covi = If[cov =!= 1 && met=!="WSVD", Inverse[Chop[weight.cov.ConjugateTranspose[weight]]], cov];

	(*Make sensitivitymap if needed*)
	sent = If[met=!="WSVD",	If[StringTake[met, 6] === "Roemer" && sen === 1, 
			MakeSense[sig, cov, SenseRescale -> OptionValue[SenseRescale]],sen],sen];
	
	(*put ncoils as last diemsnions sensitivity*)
	If[sent =!= 1, sent = weight.sent];
	sent = If[ArrayDepth[sent] > 1, RotateDimensionsLeft[sent], sent];
		
	(*perform ND reconstruction for (coils,ND)*)
	rec = Switch[OptionValue[Method],
		"Average", MeanCombine[sig],
		"RootSumSquares", If[covi === 1, RSSCombine[sigt], RSSCovCombine[sigt, covi]],
		"RootSumSquaresSNR", If[covi === 1, $Failed, Abs@RSSCovCombineSNR[sigt, covi]],
		"RoemerEqualNoise", If[covi === 1, $Failed, RoemerNCombine[sigt, sent, covi]],
		"RoemerEqualNoiseSNR", If[covi === 1, $Failed, Abs@RoemerNCombineSNR[sigt, sent, covi]],
		"RoemerEqualSignal", If[covi === 1, $Failed, RoemerSCombine[sigt, sent, covi]],
		"RoemerEqualSignalSNR", If[covi === 1, $Failed, Abs@RoemerSCombineSNR[sigt, sent, covi]],
		"WSVD", If[covi === 1, $Failed, WSVDCombine[sigt, cov]],
		_, Return[$Failed]
	];
	rec
]


(* ::Subsubsection::Closed:: *)
(*MakeSense*)


Options[MakeSense] = {SenseRescale -> True}

SyntaxInformation[MakeSense] = {"ArgumentsPattern" -> {_, _, OptionsPattern[]}};

MakeSense[coils_, cov_, OptionsPattern[]] := Block[{sos, scale, dim, low, sense},
	If[OptionValue[SenseRescale],
		sos = CoilCombine[coils, cov, Method -> "RootSumSquares"];
		DevideNoZero[#1, sos, "Comp"] & /@ coils
		,
		dim = Dimensions[coils][[2 ;;]];
		low = HammingFilterData[FourierRescaleData[coils, 0.5]];
		sos = CoilCombine[low, cov, Method -> "RootSumSquares"];
		sense = HammingFilterData[DevideNoZero[#1, sos, "Comp"] & /@ low];
		FourierRescaleData[sense, dim]
	]
]



(* ::Subsubsection::Closed:: *)
(*RSS*)


MeanCombine[sig_] := Mean[sig];


RSSCombine = Compile[{{sig, _Complex, 1}}, 
	Abs@Sqrt[sig.Conjugate[sig]],
	RuntimeOptions -> "Speed", RuntimeAttributes -> {Listable}];


RSSCovCombine = Compile[{{sig, _Complex, 1}, {cov, _Complex, 2}}, 
	Abs@Sqrt[sig.cov.Conjugate[sig]],
	RuntimeOptions -> "Speed", RuntimeAttributes -> {Listable}];


RSSCovCombineSNR = Compile[{{sig, _Complex, 1}, {cov, _Complex, 2}}, 
	Sqrt[2] Abs@Sqrt[Conjugate[sig].cov.sig],
	RuntimeOptions -> "Speed", RuntimeAttributes -> {Listable}];


(* ::Subsubsection::Closed:: *)
(*Roemer equal noise*)


RoemerNCombine = Compile[{{sig, _Complex, 1}, {sen, _Complex, 1}, {cov, _Complex, 2}}, 
	(sig.cov.Conjugate[sen])/Sqrt[sen.cov.Conjugate[sen]],
	RuntimeOptions -> "Speed", RuntimeAttributes -> {Listable}];


RoemerNCombineSNR = Compile[{{sig, _Complex, 1}, {sen, _Complex, 1}, {cov, _Complex, 2}}, 
	Sqrt[2] Abs[(Conjugate[sen].cov.sig)]/Sqrt[Conjugate[sen].cov.sen], 
	RuntimeOptions -> "Speed", RuntimeAttributes -> {Listable}];


(* ::Subsubsection::Closed:: *)
(*Roemer equal signal*)


RoemerSCombine = Compile[{{sig, _Complex, 1}, {sen, _Complex, 1}, {cov, _Complex, 2}}, 
	(sig.cov.Conjugate[sen])/(sen.cov.Conjugate[sen]),
	RuntimeOptions -> "Speed", RuntimeAttributes -> {Listable}];


RoemerSCombineSNR = Compile[{{sig, _Complex, 1}, {sen, _Complex, 1}, {cov, _Complex, 2}}, 
	Sqrt[2] Abs[(Conjugate[sen].cov.sig)]/(Conjugate[sen].cov.sen),
	RuntimeOptions -> "Speed", RuntimeAttributes -> {Listable}];


(* ::Subsubsection::Closed:: *)
(*WSVD*)


WSVDCombine[sig_, cov_] := Block[{weight},
	weight = CovToWeight[cov];
	Map[WSVDCombineT[#, weight] &, sig, {-3}]
];


CovToWeight[cov_] := Conjugate[DiagonalMatrix[Sqrt[1./#[[1]]]].#[[2]] &[Eigensystem[cov]]];


WSVDCombineT[sig_, weight_] := Block[{u, s, v, scale},
	{u, s, v} = SingularValueDecomposition[weight.sig,1];
	scale = -Norm[#] Normalize[First@#] &[weight.u[[All, 1]]];
	scale Conjugate[v[[All, 1]]] s[[1, 1]] 
];


(* ::Subsubsection::Closed:: *)
(*NormalizeSpectra*)


SyntaxInformation[NormalizeSpectra] = {"ArgumentsPattern" -> {_}};

NormalizeSpectra[spec_] := 1000. Sign[Re@Mean[Flatten[spec]]] (spec/Max[Abs[spec]])


(* ::Subsection:: *)
(*HammingFilter*)


(* ::Subsubsection::Closed:: *)
(*MakeHammingFilter*)


SyntaxInformation[MakeHammingFilter]={"ArgumentsPattern"->{_}}

MakeHammingFilter[size_] := MakeHammingFilteri[size]

MakeHammingFilteri[{zi_?IntegerQ, yi_?IntegerQ, xi_?IntegerQ}] := MakeHammingFilteri[{zi, yi, xi}] = MakeHammingFilterI[Transpose[{-Floor[{xi, yi, zi}/2], Ceiling[{xi, yi, zi}/2] - 1}]];

MakeHammingFilteri[{yi_?IntegerQ, xi_?IntegerQ}] := MakeHammingFilteri[{yi, xi}] = MakeHammingFilterI[Transpose[{-Floor[{xi, yi}/2], Ceiling[{xi, yi}/2] - 1}]];

MakeHammingFilteri[{xi_?IntegerQ}] := MakeHammingFilteri[{xi}] = MakeHammingFilteri[xi];

MakeHammingFilteri[xi_?IntegerQ] := MakeHammingFilteri[xi] = MakeHammingFilterI[{-Floor[xi/2], Ceiling[xi/2] - 1}];

MakeHammingFilterI[{{xs_?IntegerQ, xe_?IntegerQ}, {ys_?IntegerQ, ye_?IntegerQ}, {zs_?IntegerQ, ze_?IntegerQ}}] := MakeHammingFilterI[{{xs,xe},{ys,ye},{zs,zs}}] = Block[{xm, ym, zm},
	{xm, ym, zm} = Max /@ Abs[{{xs, xe}, {ys, ye}, {zs, ze}}];
	Table[Ham[x, xm] Ham[y, ym] Ham[z, zm], {z, zs, ze}, {y, ys, ye}, {x, xs, xe}]
]

MakeHammingFilterI[{{xs_?IntegerQ, xe_?IntegerQ}, {ys_?IntegerQ, ye_?IntegerQ}}] := MakeHammingFilterI[{{xs,xe},{ys,ye}}] = Block[{xm, ym},
	{xm, ym} = Max /@ Abs[{{xs, xe}, {ys, ye}}];
	Table[Ham[x, xm] Ham[y, ym], {y, ys, ye}, {x, xs, xe}]
]

MakeHammingFilterI[{xs_?IntegerQ, xe_?IntegerQ}] := MakeHammingFilterI[{xs,xe}] = Block[{xm},
	xm = Max[Abs[{xs, xe}]];
	Table[Ham[x, xm], {x, xs, xe}]
]


Ham[x_, xm_] := (0.54 + 0.46 Cos[(Pi x)/xm])


(* ::Subsubsection::Closed:: *)
(*HammingFilterData*)


SyntaxInformation[HammingFilterData] = {"ArgumentsPattern"->{_}}

HammingFilterData[data_]:= Block[{ham},
	If[ArrayDepth[data]===4,
		ham = MakeHammingFilter[Dimensions[data[[1]]]];
		FourierShifted[ham InverseFourierShifted[#]]&/@data
		,
		FourierShifted[MakeHammingFilter[Dimensions[data]] InverseFourierShifted[data]]
	]
]


(* ::Subsubsection::Closed:: *)
(*HammingFilterCSI*)


SyntaxInformation[HammingFilterCSI]={"ArgumentsPattern"->{_,_.}}

HammingFilterCSI[data_] := RotateDimensionsLeft[HammingFilterData[RotateDimensionsRight[data]]]


(* ::Subsubsection::Closed:: *)
(*DeconvolveCSIdata*)


Options[DeconvolveCSIdata]= {WienerRegularization->0.007, DeconvolutionMethod->"Wiener"}

SyntaxInformation[DeconvolveCSIdata]={"ArgumentsPattern"->{_,_.,OptionsPattern[]}}

DeconvolveCSIdata[spectra_, opts:OptionsPattern[]] := DeconvolveCSIdata[spectra,1,opts]  

DeconvolveCSIdata[spectra_, hami_,OptionsPattern[]] := Block[{dim, filt, spectraOut, ham, reg},
	reg = OptionValue[WienerRegularization];
	
	(*make tha hamming filter*)
	dim = Dimensions[spectra][[;; -2]];
	ham = If[hami===1,MakeHammingFilter[dim],hami];
	
	(*make the complex hamming filter point spread function and take the real part*)
	filt = Abs@FourierShift[ShiftedInverseFourier[ArrayPad[ham, Transpose[{Floor[dim/2], Ceiling[dim/2]}]]]];
	filt = DevideNoZero[filt, Total[Flatten[filt]], "Comp"];
	
	(*zero pad the spectra by factor two*)
	spectraOut = FourierRescaleData[RotateDimensionsRight[spectra]];
	
	(*perform the deconvolution*)
	Switch[OptionValue[DeconvolutionMethod],
		"Wiener",
		spectraOut = Map[(Exp[Arg[#] I] ListDeconvolve[filt, Abs@#, Method->{"Wiener", reg}]) &, spectraOut];
		,_,
		spectraOut = Map[(
			Exp[Arg[#] I] ListDeconvolve[filt, Abs@#,
				Padding -> "Periodic", Method -> {"SteepestDescent", "Preconditioned" -> False}, MaxIterations -> 10]
			) &, spectraOut];
	];
	
	(*rescale to original dimensions*)
	RotateDimensionsLeft[FourierRescaleData[#, dim] & /@ spectraOut]
]


(* ::Subsubsection::Closed:: *)
(*FourierRescaleData*)


SyntaxInformation[FourierRescaleData]={"ArgumentsPattern"->{_,_.}}

FourierRescaleData[data_, factor_:2] := Block[{dim, pad, scale, fac, new},
	(*get the data dimensions*)
	dim = Switch[ArrayDepth[data],
		2, Dimensions[data],
		3, Dimensions[data],
		4, Dimensions[data][[2 ;;]]
	];
	
	fac = N@Clip[If[NumberQ[factor], (0 dim + 1) factor, factor/dim], {0.0001, Infinity}];
	scale = Times@@fac;
	new = Round[dim fac] /. 0 -> 1;
	
	pad = If[#[[1]] < 1, 
		{Floor[#[[2]]], Ceiling[#[[2]]]}, 
		{Ceiling[#[[2]]], Floor[#[[2]]]}
	] & /@ Thread[{fac, N[(new - dim)/2]}];
		
	Switch[ArrayDepth[data],
		2, scale FourierShifted[ArrayPad[InverseFourierShifted[data], pad]],
		3, scale FourierShifted[ArrayPad[InverseFourierShifted[data], pad]],
		4, scale FourierShifted[ArrayPad[InverseFourierShifted[#], pad]] & /@ data
	]
]


(* ::Subsection:: *)
(*Recon Functions*)


(* ::Subsubsection::Closed:: *)
(*Coil weighted recon*)


Options[CoilWeightedRecon] = {
	EchoShiftData -> 0, 
	CoilSamples -> 2, 
	Method -> "RoemerEqualSignal", 
	OutputSense->False,
	RescaleRecon->True,
	ReconFilter->False
	};

SyntaxInformation[CoilWeightedRecon]={"ArgumentsPattern"->{_, _, _, _., OptionsPattern[]}}

CoilWeightedRecon[kspace_, noise_, head_, ops:OptionsPattern[]]:=CoilWeightedRecon[kspace, noise, head, 0,  ops]

CoilWeightedRecon[kspace_, noise_, head_, sensi_, OptionsPattern[]] := Block[{shift, coilData, cov, sens, 
	arrD, cDim, recon, encDim},
	shift = OptionValue[EchoShiftData];
	encDim = "number_of_encoding_dimensions"/.head;
	cDim = (encDim + 1);

	(*make Image Data*)
	coilData = Switch[encDim,
		2, Map[FourierKspace2D[#, head, OptionValue[ReconFilter]] &, kspace, {-4}],
		3, FourierKspace3D[kspace, head, OptionValue[ReconFilter]]
	];

	arrD = ArrayDepth[coilData];
	cov = NoiseCovariance[noise];
	
	(*shift the echos to center if needed*)
	If[shift =!= 0,
		coilData = Table[If[EvenQ[i],
			RotateRight[coilData[[i]], {0, 0, 0, shift[[1]]}],
			RotateLeft[coilData[[i]], {0, 0, 0, shift[[2]]}]
		], {i, 1, Length[coilData]}]
	];
	
	If[sensi===0,
		(*make coil sensitivity*)
		sens = Map[HammingFilterData, Nest[Mean, coilData, ArrayDepth[coilData] - (encDim + 1)], {-(encDim + 1)}];
		sens = MakeSense[sens, cov];
		,
		sens = sensi
	];
	
	(*perform the recon*)
Print[{cDim,arrD,Dimensions@coilData,Dimensions@sens}];

	recon = If[cDim === arrD,
		CoilCombine[coilData, cov, sens, Method -> OptionValue[Method]],
		CoilCombine[#, cov, sens, Method -> OptionValue[Method]] & /@ coilData
	];
	
	(*scale to proper values*)
	If[OptionValue[RescaleRecon],recon = 1000. recon/Max[Abs[recon]]];
	
	If[OptionValue[OutputSense],
		{#[recon] & /@ {Abs, Arg, Re, Im},sens},
		#[recon] & /@ {Abs, Arg, Re, Im}
	]
]


(* ::Subsubsection::Closed:: *)
(*Coil weighted recon CSI*)


Options[CoilWeightedReconCSI] = {HammingFilter -> False, CoilSamples -> 5, Method -> "WSVD", NormalizeOutputSpectra->True, AcquisitionMethod->"Fid"};

SyntaxInformation[CoilWeightedReconCSI]={"ArgumentsPattern"->{_, _, _, _., OptionsPattern[]}}

CoilWeightedReconCSI[kspace_, noise_, head_, ops:OptionsPattern[]]:=CoilWeightedReconCSI[kspace, noise, head, 0, ops]

CoilWeightedReconCSI[kspace_, noise_, head_, sense_, ops:OptionsPattern[]] := Block[{
		fids, spectra, cov, coils, sosCoils, sens,readout, 
		nenc, met, noCoils
	},
	readout = OptionValue[AcquisitionMethod];
	nenc = "number_of_encoding_dimensions" /. head;
	met = Switch[nenc, 3, "2D", 4, "3D"];
	noCoils = ArrayDepth[kspace] =!= nenc + 1;
	
	spectra = If[noCoils,
		(*no coil combination for 2D or 3D CSI*)
		fids = RotateDimensionsLeft[FourierKspaceCSI[kspace, head, met]];
		Map[ShiftedFourier[#, readout] &, fids, {-2}]
		,
		(*coil combination for 2D or 3D CSI*)
		fids = Transpose[FourierKspaceCSI[#, head, met] & /@ kspace];
		spectra = RotateDimensionsRight[Map[ShiftedFourier[#, readout] &, RotateDimensionsLeft[fids], {-2}]];
		
		(*noise correlation, inverse and withening matrix*)
		cov = NoiseCovariance[noise];
		Switch[OptionValue[Method],
			"Roemer",
			(*make coil sensitivity using the first 5 samples of the fid*)
			(*sens = MakeSense[HammingFilterCSI[Mean[fids[[1 ;; OptionValue[CoilSamples]]]]],cov];*)
			sens = If[sense === 0,
				MakeSense[Mean[fids[[1 ;; OptionValue[CoilSamples]]]],cov, SenseRescale -> False],
				sense
			];
			(*perform the recon*)
			RotateDimensionsLeft[CoilCombine[#, cov, sens, Method -> "RoemerEqualNoise"] & /@ spectra]
			,
			"WSVD",
			CoilCombine[spectra, cov, Method -> "WSVD"]
		]
	];
	
	(*Normalize spectra*)
	If[OptionValue[NormalizeOutputSpectra],	spectra = NormalizeSpectra[spectra]];
	If[OptionValue[HammingFilter], spectra = HammingFilterCSI[spectra]];

	(*make 2D 3D*)
	If[nenc===3, {spectra}, spectra]
]



(* ::Section:: *)
(*End Package*)


End[]

EndPackage[]
