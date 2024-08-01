(* ::Package:: *)

(* ::Title:: *)
(*QMRITools MaskingTools*)


(* ::Subtitle:: *)
(*Written by: Martijn Froeling, PhD*)
(*m.froeling@gmail.com*)


(* ::Section:: *)
(*Begin Package*)


BeginPackage["QMRITools`MaskingTools`", Join[{"Developer`"}, Complement[QMRITools`$Contexts, {"QMRITools`MaskingTools`"}]]];


(* ::Section:: *)
(*Usage Notes*)


(* ::Subsection::Closed:: *)
(*Functions*)


NormalizeData::usage = 
"NormalizeData[data] normalizes the data to the mean signal of the data. For 4D data it normalizes to the first volume of the 4th dimension.
NormalizeData[data, mask] normalizes the data based on the mean signal only within the mask."

NormalizeMeanData::usage = 
"NormalizeMeanData[data] calculates the mean normalized data from a 4D dataset."

HomogenizeData::usage = 
"HomogenizeData[data, mask] tries to homoginize the data within the mask by removing intensity gradients."

FitGradientMap::usage = 
"FitGradientMap[data, ord] fit of gradient trough all non zero values withing the data."


Mask::usage =
"Mask[data] creates a mask by automatically finding a threshold.
Mask[data, min]creates a mask which selects only data above the min value.
Mask[data,{min,max}] creates a mask which selects data between the min and max value."

SmoothMask::usage = 
"SmoothMask[mask] generates one clean masked volume form a noisy mask."

MaskData::usage = 
"MaskData[data, mask] applies a mask to data. mask can be 2D or 3D, data can be 2D, 3D or 4D."

MaskSegmentation::usage = 
"MaskSegmentation[seg, mask] applies a mask to a splited segmentation seg from SplitSegmentations. 
The mask is 3D, seg is 4D."

GetMaskData::usage =
"GetMaskData[data, mask] retruns the data selected by the mask."

MeanSignal::usage = 
"MeanSignal[data] calculates the mean signal per volume of 4D data.
MeanSignal[data, pos] calculates the mean signal per volume of 4D data for the given list of positions."


SplitSegmentations::usage = 
"SplitSegmentations[segmentation] splits a lable mask from ITKsnap or slicer3D in seperate masks and label numbers.
Output is masks and label numbers, {mask, labs}."

GetSegmentationLabels::usage = 
"GetSegmentationLabels[segmentation] gives a list of all labels in the segmentation."

RescaleSegmentation::usage = 
"RescaleSegmentation[data, dim] rescales segmentations to given dimensions.
RescaleSegmentation[data, {vox1, vox2}] rescales segmentations from voxelsize vox1 to voxelsize vox2."

MergeSegmentations::usage = 
"MergeSegmentations[masks, labels] generates an ITKsnap or slices3D compatible segmentation from individual masks and label numbers.
Output is a labled segmentation."

SelectSegmentations::usage =
"SelectSegmentations[seg, labs] selects only the segmentaions from seg with label number labs."

ReplaceSegmentations::usage =
"ReplaceSegmentations[seg, labs, new] relapaces the labels labs form the segmentation seg for labels new. Both labs and new should
be lists of integers of the same size. If seg contains more labels then given in labs these will be replaced by 0." 

SmoothSegmentation::usage =
"SmoothSegmentation[segmentation] smooths segmentations and removes the overlaps between multiple segmentations." 

RemoveMaskOverlaps::usage = 
"RemoveMaskOverlaps[mask] removes the overlaps between multiple masks. Mask is a 4D dataset with {z, masks, x, y}."

GetCommonSegmentation::usage = 
"GetCommonSegmentation[dat, seg, vox] For a list of multiple datasets dat the common segmentations from the list seg are determined.
Output is a list of segmentations where for each region only the part present in all datasets is selected."


DilateMask::usage=
"DilateMask[mask,size] if size > 0 the mask is dilated and if size < 0 the mask is eroded."

SegmentMask::usage = 
"SegmentMask[mask, n] divides a mask in n segments along the slice direction, n must be an integer. The mask is divided in n equal parts where each parts has the same number of slices."

SegmentationVolume::usage = 
"SegmentationVolume[seg] calculates the volume of each label in the segmentation."


ROIMask::usage = 
"ROIMask[maskdim, {name->{{{x,y},slice}..}..}] crates mask from coordinates x and y at slice. 
maskdim is the dimensions of the output {zout,xout,yout}."


(* ::Subsection::Closed:: *)
(*Options*)


NormalizeMethod::usage = 
"NormalizeMethod is an option for NormalizeData. Can be \"Set\" or \"Volumes\" wich normalizes to the first volume or normalizes each volume individually, respectively.
If \"Uniform\" normalizes the histogram of the data to have a uniform distribution between 0 and 1 where 0 is treated as background of the data."

FitOrder::usage = 
"FitOrder is an option for HomogenizeData. It specifies the order of harmonics to be used for the homogenization."

MaskSmoothing::usage = 
"MaskSmoothing is an options for Mask, SmoothMask and SmoothSegmentation, if set to True it smooths the mask, by closing holse and smoothing the contours."

MaskComponents::usage =
"MaskComponents is an option for Mask, SmoothMask and SmoothSegmentation. Determinse the amount of largest clusters used as mask." 

MaskClosing::usage =
"MaskClosing  is an option for Mask, SmoothMask and SmoothSegmentation. The size of the holes in the mask that will be closed." 

MaskDilation::usage = 
"MaskDilation is an option for Mask, SmoothMask and SmoothSegmentation. If the value is greater than 0 it will dilate the mask, if the value is smaller than 0 it will erode the mask."

MaskFiltKernel::usage =
"MaskFiltKernel is an option for Mask, SmoothMask and SmoothSegmentation. How mucht the contours are smoothed." 

SmoothItterations::usage =
"SmoothItterations is an option for Mask, SmoothMask and SmoothSegmentation and defines how often the smoothing is repeated."

GetMaskOutput::usage = 
"GetMaskOutput is an option for GetMaskData. Defaul is \"Slices\" which gives the mask data per slices. Else the entire mask data is given as output."

GetMaskOnly::usage = 
"GetMaskOnly is an option for GetMaskData. If set True all values in the mask are given, if set False only non zero values in the mask are give."

UseMask::usage = 
"UseMask is a function for MeanSignal and DriftCorrect."


(* ::Subsection::Closed:: *)
(*Error Messages*)


Mask::tresh = "Given treshhold `1` value is not a vallid input, must be a number for min treshhold only or a vector {min tresh, max tresh}."

GetMaskData::tresh = "The dimensions of the data and the mask must be the same, dataset: `1`, mask: `2`."

MaskData::dim = "Dimensions are not equal, data: `1`, mask `2`." 

MaskData::dep = "Data dimensions should be 2D, 3D or 4D. Mask dimensions should be 2D or 3D. Data is `1`D and Mask is `2`D."

ROIMask::war = "there are more slices in the roi set than in the given dimensions."


(* ::Section:: *)
(*Functions*)


Begin["`Private`"]


(* ::Subsection:: *)
(*Normalize Functions*)


(* ::Subsubsection::Closed:: *)
(*NormalizeData*)


SyntaxInformation[NormalizeData] = {"ArgumentsPattern" -> {_,_., OptionsPattern[]}};

Options[NormalizeData] = {NormalizeMethod -> "Set"}

SyntaxInformation[NormalizeData] = {"ArgumentsPattern" -> {_, _., OptionsPattern[]}};

NormalizeData[data_, opts : OptionsPattern[]] := Block[{ndat, mask},
	If[OptionValue[NormalizeMethod]=!="Uniform",
		ndat = Switch[ArrayDepth[data], 3, data, 4, Mean@Transpose@data];
		mask = Mask[NormDat[ndat - Min@ndat, 0.]];
		NormalizeData[data, mask, opts]
		,
		NormDatC[data]
	]
]

NormalizeData[data_, msk_, opts : OptionsPattern[]] := Block[{dat, mn, min, dato, mask},
	mask = Normal@msk;
	dato = data - Min[data];
	mn = Switch[ArrayDepth[data],
		3, MeanNoZero[Flatten[mask dato]],
		4, Switch[OptionValue[NormalizeMethod],
			"Volumes", MedianNoZero[Flatten[mask #]] & /@ Transpose[dato],
			_, MedianNoZero[Flatten[mask dato[[All, 1]]]]
		]
	];
	NormDat[dato, mn]
]


(*normalization towards uniform distribution*)
NormDatC = Compile[{{dat, _Real, 3}}, Block[{fl, flp, min, max, bins, cdf, n},
	n = 512;
	fl = Flatten[dat];
	flp = Pick[fl, Unitize[fl], 1];
	{min, max} = MinMax[flp];
	bins = BinCounts[flp, {min, max, (max - min)/n}];
	cdf = Prepend[N[Accumulate[bins]/Total[bins]], 0.];
	Map[cdf[[# + 1]] &, Clip[Floor[(dat - min)/(max - min)  n], {0, n}, {0, n}], {-2}]
], RuntimeAttributes -> {Listable}, RuntimeOptions -> "Speed", Parallelization -> True];


(*normalization towards median of given valueue*)
NormDat[dat_, mn_] := ToPackedArray[100. Which[
	mn===0., dat/MedianNoZero[Flatten@dat],
	ListQ[mn],Transpose[Transpose[dat]/mn],
	True, dat/mn]
]


(* ::Subsubsection::Closed:: *)
(*NormalizeMeanData*)


SyntaxInformation[NormalizeMeanData] = {"ArgumentsPattern" -> {_,_., OptionsPattern[]}};

NormalizeMeanData[data_] := NormalizeData[Mean@Transpose@data]

NormalizeMeanData[data_, mask_] := NormalizeData[Mean@Transpose@data, mask]


(* ::Subsubsection::Closed:: *)
(*HomogenizeData*)


Options[HomogenizeData] = {FitOrder->5}

SyntaxInformation[HomogenizeData] = {"ArgumentsPattern" -> {_, _., OptionsPattern[]}};

HomogenizeData[dat_, opts:OptionsPattern[]]:=HomogenizeData[dat, Unitize[dat], opts]

HomogenizeData[dat_, mask_, OptionsPattern[]] := Block[{fit},
	fit = FitGradientMap[Erosion[mask, 1] GaussianFilter[dat, 5], OptionValue[FitOrder]];
	NormalizeData[Clip[mask DevideNoZero[dat, fit], {0, 3}, {0, 0}]]
]


FitGradientMap[data_, ord_] := Block[{func, x, y, z, coor, mod, min, max},
	Clear[x, y, z];
	coor = Flatten[MapIndexed[ReleaseHold@If[#1 == 0, Hold[Sequence[]], Join[#2, {#1}]] &, data, {3}], 2];
	mod = DeleteDuplicates[Times @@ # & /@ Tuples[{1, x, y, z}, ord]];
	
	{min, max} = Quantile[coor[[All, 4]], {0.15, 0.95}];
	func = Fit[Select[coor, min < #[[4]] < max &], mod, {x, y, z}];
	
	{x, y, z} = RotateDimensionsRight[Array[{#1, #2, #3} &, Dimensions[data]]];
	func
]


(* ::Subsection:: *)
(*Masking*)


(* ::Subsubsection::Closed:: *)
(*Mask*)


Options[Mask] = {MaskSmoothing -> False, MaskComponents -> 2, MaskClosing -> 5, MaskFiltKernel -> 2, MaskDilation -> 0, SmoothItterations->3};

SyntaxInformation[Mask] = {"ArgumentsPattern" -> {_, _., OptionsPattern[]}};

Mask[dat_, opts : OptionsPattern[]] := Mask[dat, {0, 0}, opts]

Mask[dat_?ArrayQ, tr_?NumberQ, opts : OptionsPattern[]] := Mask[dat, {tr, 1.1 Max[dat]}, opts]

Mask[inp : {{_?ArrayQ, _} ..}, opts : OptionsPattern[]] := Times @@ (Mask[#, opts] & /@ inp)

Mask[{dat_?ArrayQ, tr_?NumberQ}, opts : OptionsPattern[]] := Mask[dat, tr, opts]

Mask[{dat_?ArrayQ, tr_?VectorQ}, opts : OptionsPattern[]] := Mask[dat, tr, opts]

Mask[dat_?ArrayQ, tr_?VectorQ, opts:OptionsPattern[]]:= Block[{mask, tresh, dataD, datN, data, dil},
	
	(*perform data checks*)
	data = ToPackedArray@N@Normal@dat;
	dataD = ArrayDepth[data];
	If[Length[tr] =!= 2, Return@Message[Mask::tresh, tr]];
	If[ArrayDepth[data] > 3, Return@Message[Mask::dep, dataD]];
	
	(*perform the masking*)		
	mask = If[tr === {0, 0},
		(*no threshhold*)
		ImageData[Binarize[If[dataD == 2, Image, Image3D][Rescale[data, {1, 0.95} MinMax[data]]]]],
		(*threshhold*)
		UnitStep[data - tr[[1]]] - UnitStep[data - tr[[2]]]
	];
	
	(*smooth the mask if needed*)
	Normal@If[OptionValue[MaskSmoothing], SmoothMask[mask, FilterRules[{opts, Options[Mask]}, Options[SmoothMask]]], mask]
]


(* ::Subsubsection::Closed:: *)
(*SmoothMask*)


Options[SmoothMask] = {MaskComponents->1, MaskClosing->5, MaskFiltKernel->2, MaskDilation -> 0, SmoothItterations->3}

SyntaxInformation[SmoothMask] = {"ArgumentsPattern" -> {_, OptionsPattern[]}};

SmoothMask[msk_, OptionsPattern[]] := Block[{itt, dil, pad, close, obj, filt, mask, crp, dim},
	
	(*get the options*)
	itt = Round[OptionValue[SmoothItterations]];(*how much the smoothing is repeated*)
	dil = Round[OptionValue[MaskDilation]];(*how much the mask is eroded or dilated*)
	obj = OptionValue[MaskComponents];(*number of objects that are maintained*)
	filt = OptionValue[MaskFiltKernel];(*how much smooting*)
	close = OptionValue[MaskClosing];(*close holes in mask*)
	pad = Max[{5,2 close}];

	dim = Dimensions@msk;
	{mask,crp} = AutoCropData[msk];

	(*perform padding to avoid border effects*)
	mask = ArrayPad[Normal@mask, pad];
	(*select number of mask components*)
	mask = ImageData[SelectComponents[If[ArrayDepth[mask]==2, Image, Image3D][mask], "Count", -obj]];
	(*perform the closing opperation*)
	mask = Closing[mask, close];
	(*perform itterative smoothing*)
	mask = ImageData@Nest[Round[GaussianFilter[Erosion[Round[GaussianFilter[Dilation[#, 1], filt] + 0.05], 1], filt] + 0.05]&, Image3D@mask, itt];
	(*perform reverse padding dilation if needed*)
	mask = ArrayPad[mask, -pad];
	mask = DilateMask[mask, dil];
	
	(*reverse cropping*)
	SparseArray[ReverseCrop[mask, dim, crp]]
]


(* ::Subsubsection::Closed:: *)
(*DilateMask*)


SyntaxInformation[DilateMask] = {"ArgumentsPattern" -> {_, _}};

DilateMask[seg_, size_] := Block[{sz, fun},
	sz = Abs[Round[size]];

	If[sz =!= 0,
		(*see if dilation of erosion*)
		fun = If[size > 0, Dilation, Erosion];

		(*3D or 4D data*)
		SparseArray@Switch[ArrayDepth[seg],
			3, DilateMaskI[seg, fun, sz],
			4, Transpose[DilateMaskI[#, fun, sz] & /@ Transpose[seg]]
		]
		,
		(*if size is 0 dont do anything*)
		SparseArray@seg
	]
]

DilateMaskI[seg_, fun_, size_] := Round[SparseArray[ReverseCrop[fun[#[[1]], size], Dimensions[seg], #[[2]]]] &[AutoCropData[seg]]]


(* ::Subsubsection::Closed:: *)
(*MaskData*)


SyntaxInformation[MaskData] = {"ArgumentsPattern" -> {_, _}};

MaskData[data_, mask_]:=Block[{dataD, maskD,dimD,dimM,out},
	(*get the data properties*)
	dataD = ArrayDepth[data];
	maskD = ArrayDepth[mask];
	dimD = Dimensions[data];
	dimM = Dimensions[mask];
	
	(*determine how to mask the data*)
	out = Switch[{dataD,maskD},
		{2,2}, If[dimD == dimM, mask data, 1],
		{3,3}, If[dimD == dimM, mask data, 1],
		{3,2}, If[dimD[[2;;]] == dimM, mask # &/@ data, 1],
		{4,3}, Which[
			dimD[[2;;]] == dimM, mask # & /@ data, 
			dimD[[{1,3,4}]] == dimM, Transpose[mask # & /@ Transpose[data]], 
			True, Return[Message[MaskData::dim, dimD, dimM];$Failed]],
		_, Return[Message[MaskData::dep, dataD, maskD];,$Failed]
	];
	
	(*make the output*)
	ToPackedArray@N@Normal@out
]


(* ::Subsubsection::Closed:: *)
(*MaskSegmentation*)


SyntaxInformation[MaskSegmentation] = {"ArgumentsPattern" -> {_, _}};

MaskSegmentation[seg_, mask_] := Block[{dim, sc, cr},
	msk = Normal@mask;
	dim = Dimensions[seg[[All, 1]]];
	Transpose[(
		{sc, cr} = AutoCropData[#];
		Round@SparseArray@ReverseCrop[ApplyCrop[msk, cr] sc, dim, cr]
	) & /@ Transpose[seg]]
]


(* ::Subsubsection::Closed:: *)
(*GetMaskData*)


Options[GetMaskData] = {GetMaskOutput -> "All", GetMaskOnly->False}

SyntaxInformation[GetMaskData] = {"ArgumentsPattern" -> {_, _, OptionsPattern[]}};

GetMaskData[data_?ArrayQ, mask_, opts:OptionsPattern[]] := Block[{out},
	Which[
		ArrayDepth[data]===4&&ArrayDepth[mask]===3, 
		GetMaskData[#, mask, opts]&/@Transpose[data]
		,
		ArrayDepth[data]===3&&ArrayDepth[mask]===4, 
		GetMaskData[data, #, opts]&/@Transpose[mask]
		,
		True,
		If[!(Dimensions[data]=!=Dimensions[mask] || Drop[Dimensions[data], {2}]=!=Dimensions[mask]),
			Retrun[Message[GetMaskData::dim,Dimensions[data],Dimensions[mask]];$Failed]
			,
			out = Switch[OptionValue[GetMaskOutput],
				"Slices", MapThread[Pick[Chop[Flatten[N[#1]]], Unitize[Flatten[Normal@#2]], 1]&, {data, mask}, ArrayDepth[data]-2],
				"Sparse", (data mask)["ExplicitValues"],
				_, Pick[Flatten[N[data]], Unitize[Flatten[Normal@mask]], 1]
			];

			out = Switch[OptionValue[GetMaskOutput],
				"Mean", Mean[out],
				"Median", Median[out],
				_, out			
			];
			(*select only non zero values if mask only to false*)
			If[OptionValue[GetMaskOnly],out,Pick[out, Unitize[out], 1]]
		]
	]
]


(* ::Subsection::Closed:: *)
(*MeanSignal*)


Options[MeanSignal] = { UseMask->True }

SyntaxInformation[MeanSignal] = {"ArgumentsPattern" -> {_, _.,OptionsPattern[]}};

MeanSignal[data_, opts:OptionsPattern[]] := MeanSignal[data, "", opts];

MeanSignal[data_, posi_, OptionsPattern[]] := Block[{pos, dat, mask},
	{pos, dat} = Which[
		ListQ[posi], {posi, data[[All,posi]]},
		IntegerQ[posi], {{posi}, data[[All,posi]]},
		True, {All, data}
	];
	
	mask = If[OptionValue[UseMask], Mask[NormalizeMeanData[dat], MaskSmoothing->True], 0 dat[[All,1]] + 1];
	
	N@MeanNoZero[Flatten[#]] & /@ Transpose[MaskData[dat, mask]]
]


(* ::Subsection:: *)
(*Segmentation functions*)


(* ::Subsubsection::Closed:: *)
(*SplitSegmentations*)


SyntaxInformation[SplitSegmentations] = {"ArgumentsPattern" -> {_}};

SplitSegmentations[segI_]:=SplitSegmentations[segI, True]

SplitSegmentations[segI_, sparse_] := Block[{seg, dim, exVals, exPos, vals},
	seg = SparseArray[Round[segI]];
	dim = Dimensions[seg];

	exVals = seg["ExplicitValues"];
	exPos = seg["ExplicitPositions"];
	vals = Sort@DeleteDuplicates@exVals;
	
	seg = Transpose[SparseArray[Pick[exPos, Unitize[exVals - #], 0] -> 1, dim] & /@ vals];
	
	{If[sparse, seg, Normal@seg], vals}
]


(* ::Subsubsection::Closed:: *)
(*GetSegmentationLabels*)


GetSegmentationLabels[segI_]:= Sort[DeleteDuplicates[SparseArray[Round[segI]]["ExplicitValues"]]];


(* ::Subsubsection::Closed:: *)
(*MergeSegmentations*)


SyntaxInformation[MergeSegmentations] = {"ArgumentsPattern" -> {_,_}};

MergeSegmentations[seg_, lab_] := Block[{mt,nv},
	mt = Transpose[SparseArray[Round[seg]]];
	nv = Range[Length@lab];

	(*mapping over sparce is quicker than direct multiplication and total*)
	Normal[Total[mt[[#]] lab[[#]] & /@ nv] (1 - UnitStep[Total[mt[[#]] & /@ nv] - 2])]
]


(* ::Subsubsection::Closed:: *)
(*SelectSegmentations*)


SyntaxInformation[SelectSegmentations] = {"ArgumentsPattern" -> {_,_}};

SelectSegmentations[seg_, labSel_] := SelectReplaceSegmentations[seg, labSel, labSel]


(* ::Subsubsection::Closed:: *)
(*ReplaceSegmentations*)


SyntaxInformation[ReplaceSegmentations] = {"ArgumentsPattern" -> {_,_,_}};

ReplaceSegmentations[segm_, labSel_, labNew_] := SelectReplaceSegmentations[segm, labSel, labNew]


(* ::Subsubsection::Closed:: *)
(*SelectReplaceSegmentations*)


SelectReplaceSegmentations[segm_, labSel_, labNew_] := Block[{split, seg, lab, sel},
	split = If[Length[segm] == 2, False, True];

	{seg, lab} = If[split,  SplitSegmentations[segm], segm];
	
	sel = MemberQ[labSel, #] & /@ lab;

	If[AllTrue[sel, # === False &],
		If[split, 0 MergeSegmentations[seg, lab], {0 seg[[All,1]], {}}]
		,
		seg = Transpose[Pick[Transpose[seg], sel, True]];
		lab = Pick[lab /. Thread[labSel->labNew], sel, True];
		or = Ordering[lab];

		If[split, MergeSegmentations[seg, lab], {seg[[All,or]], lab[[or]]}]
	]
]


(* ::Subsubsection::Closed:: *)
(*SmoothSegmentation*)


Options[SmoothSegmentation] = {MaskComponents -> 1, MaskClosing -> 5, MaskFiltKernel -> 2, MaskDilation -> 0, SmoothItterations->3}

SyntaxInformation[SmoothSegmentation] = {"ArgumentsPattern" -> {_, _., OptionsPattern[]}};

SmoothSegmentation[maskIn_,  opts:OptionsPattern[]] :=SmoothSegmentation[maskIn, All, opts]

SmoothSegmentation[maskIn_, what_, opts:OptionsPattern[]] := 
 Block[{smooth,obj, md, masks, labs},
 	smooth = OptionValue[MaskFiltKernel];
	obj = OptionValue[MaskComponents];
	
	md = ArrayDepth[maskIn];

	(*split segmentations if needed*)
	If[md===3, {masks, labs} = SplitSegmentations[maskIn],	masks = maskIn];

	(*convert data to sparse Array and transpose*)
	masks = Transpose[SparseArray[Round@masks]];

	(*Get smoothed or non smoothed masks*)
	masks[[what]] = SmoothMask[#, Sequence@@FilterRules[{opts}, Options[SmoothMask]]]&/@masks[[what]];
	
	(*remove the overlaps*)
	masks = Transpose@RemoveMaskOverlapsI[SparseArray[masks]];

	If[md===3, MergeSegmentations[masks,labs], masks]
  ]


(* ::Subsubsection::Closed:: *)
(*RemoveMaskOverlaps*)


SyntaxInformation[RemoveMaskOverlaps] = {"ArgumentsPattern" -> {_}};
	
RemoveMaskOverlaps[masks_] := Transpose@RemoveMaskOverlapsI[Transpose[SparseArray[Round@masks]]];

RemoveMaskOverlapsI[masks_] := Block[{maskOver, posOver, maskInp, maskOut, z, x, y, p},
	maskOver = SparseArray[Mask[Total[masks], 1.5]];
	posOver = maskOver["ExplicitPositions"];
	maskOut = SparseArray[SparseArray[(1 - maskOver) #] & /@ masks];
	
	maskInp = maskOver Transpose[masks, {4, 1, 2, 3}];
	p = ({z, x, y} = #; {First@First[maskInp[[z, x, y]]["ExplicitPositions"]], z, x, y}) & /@posOver;
	maskOut + SparseArray[p -> 1, Dimensions[maskOut]]
]


(* ::Subsubsection::Closed:: *)
(*GetCommonSegmentation*)

SyntaxInformation[GetCommonSegmentation] = {"ArgumentsPattern" -> {_, _, _}};

GetCommonSegmentation[dat:{_?ArrayQ ..}, seg:{_?ArrayQ ..}, vox:{_?ListQ ..}] := Block[
	{dims, datC, cr, len, segs, labs, labAll, labSel, l, gr, segR},
	
	(*auto crop all the datasets*)
	dims = Dimensions /@ dat;
	{datC, cr} = Transpose[AutoCropData /@ dat];
	len = Length[datC];
	
	(*split and smooth all the segmentations*)
	{segs, labs} = Transpose[SplitSegmentations[ApplyCrop[#[[1]], #[[2]]]] & /@ Thread[{seg, cr}]];
	segs = SmoothSegmentation[#, MaskComponents -> 1, SmoothItterations -> 2] & /@ segs;
	
	(*find common labels*)
	labAll = Intersection @@ labs;
	labSel = (l = #; Flatten[Position[l, #] & /@ labAll]) & /@ labs;
	
	gr = 5 Mean@vox;
	(*find the common segmentation for each dataset*)
	Table[
		segR = Times @@ Table[
			If[tar === mov,
				segs[[tar, All, labSel[[tar]]]],
				Round@Last@RegisterDataTransform[
					{datC[[tar]], vox[[tar]]},
					{datC[[mov]], vox[[mov]]},
					{segs[[mov, All, labSel[[mov]]]], vox[[mov]]},
					MethodReg -> {"rigid", "affine", "bspline"}, Resolutions -> 3, NumberSamples -> 5000, BsplineSpacing -> gr
				]
			]
		, {mov, 1, len}];
		
		MergeSegmentations[ReverseCrop[RemoveMaskOverlaps[segR], dims[[tar]], cr[[tar]]], labAll[[labSel[[tar]]]]]
	, {tar, 1, len}]
]


(* ::Subsubsection::Closed:: *)
(*RescaleSegmentation*)


SyntaxInformation[RescaleSegmentation] = {"ArgumentsPattern" -> {_, _}};

RescaleSegmentation[seg_, vox_] := Block[{segs, val},
	If[ArrayDepth[seg] == 3,
		{segs, val} = SplitSegmentations[seg],
		segs = seg
	];
	segs = Transpose@RemoveMaskOverlapsI[SparseArray[SparseArray[Round[RescaleData[Normal[#], vox, InterpolationOrder -> 1]]] & /@Transpose[segs]]];
	If[ArrayDepth[seg] == 3, MergeSegmentations[segs, val], segs]
]



(* ::Subsubsection::Closed:: *)
(*SegmentMask*)


SyntaxInformation[SegmentMask] = {"ArgumentsPattern" -> {_, _, _.}};

SegmentMask[mask_, seg_?IntegerQ] := Block[{pos, f, l, sel, out},
	pos = Flatten@Position[Unitize[Total[Flatten[#]]] & /@ mask, 1];
	{f, l} = {First[pos], Last[pos]};
	sel = Partition[Round[Range[f, l, ((l - f)/seg)]], 2, 1] + Append[ConstantArray[{0, -1}, seg - 1], {0, 0}];
	out = ConstantArray[0*mask, seg];
	Table[out[[i, sel[[i, 1]] ;; sel[[i, 2]]]] = mask[[sel[[i, 1]] ;; sel[[i, 2]]]], {i, 1, seg}];
	out
]


(* ::Subsubsection::Closed:: *)
(*SegmentationVolume*)


SyntaxInformation[SegmentationVolume] = {"ArgumentsPattern" -> {_, _.}};

SegmentationVolume[seg_] := SegmentationVolume[seg, {0, 0, 0}]

SegmentationVolume[seg_, vox : {_?NumberQ, _?NumberQ, _?NumberQ}] := 
 Block[{vol},
  vol = If[vox === {0, 0, 0}, 1, N@((Times @@ vox)/1000)];
  vol  Total[Flatten[#]] & /@ Switch[ArrayDepth[seg],
    3, Transpose[First@SplitSegmentations[seg]],
    4, Transpose[seg],
    _, Return[$Failed]
    ]
  ]


(* ::Subsection::Closed:: *)
(*ROIMask*)


SyntaxInformation[ROIMask] = {"ArgumentsPattern" -> {_, _, _.}};

ROIMask[roiDim_,maskdim_,ROI:{(_?StringQ->{{{{_?NumberQ,_?NumberQ}..},_?NumberQ}..})..}]:=
Module[{output},
	output=Map[#[[1]]->ROIMask[roiDim,maskdim,#[[2]]]&,ROI];
	Print["The Folowing masks were Created: ",output[[All,1]]];
	Return[output]
	]

ROIMask[roiDim_,maskdim_,ROI:{{_?StringQ->{{{{_?NumberQ,_?NumberQ}..},_?NumberQ}..}}..}]:=
Module[{output},
	output=Map[#[[1,1]]->ROIMask[roiDim,maskdim,#[[1,2]]]&,ROI];
	Print["The Folowing masks were Created: ",output[[All,1]]];
	Return[output]
	]

ROIMask[roiDim_,maskdim_,ROI:{{{{_?NumberQ,_?NumberQ}..},_?NumberQ}..}]:=
Module[{output,roiCor,roiSlice,msk},
	output=ConstantArray[0,Join[{roiDim[[1]]},maskdim]];
	If[ROI[[All,1]]!={{{0,0}}},
		roiCor=Round[ROI[[All,1]]];
		roiSlice=Clip[ROI[[All,2]],{1,roiDim[[1]]}];
		msk=1-ImageData[Image[Graphics[Polygon[#],PlotRange->{{0,roiDim[[3]]},{0,roiDim[[2]]}}],"Bit",ColorSpace->"Grayscale",ImageSize->maskdim]]&/@roiCor;
		MapIndexed[output[[#1]]=msk[[First[#2]]];&,roiSlice];
		];
	Return[output];
	]

ROIMask[maskdim_,ROI:{(_?StringQ->{{{{_?NumberQ,_?NumberQ}..},_?NumberQ}..})..}]:=
Module[{output},
	output=Map[#[[1]]->ROIMask[maskdim,#[[2]]]&,ROI];
	Print["The Folowing masks were Created: ",output[[All,1]]];
	Return[output]
	]

ROIMask[maskdim_,ROI:{{_?StringQ->{{{{_?NumberQ,_?NumberQ}..},_?NumberQ}..}}..}]:=
Module[{output},
	output=Map[#[[1,1]]->ROIMask[maskdim,#[[1,2]]]&,ROI];
	Print["The Folowing masks were Created: ",output[[All,1]]];
	Return[output]
	]

ROIMask[maskdim_,ROI:{{{{_?NumberQ,_?NumberQ}..},_?NumberQ}..}]:=
Module[{output, roiCor, roiSlice, msk},
 output = ConstantArray[0, maskdim];
 If[ROI[[All, 1]] != {{{0, 0}}},
  roiCor = Round[Map[Reverse[maskdim[[2 ;; 3]]]*# &, ROI[[All, 1]], {2}]];
  If[Max[ROI[[All, 2]]] > maskdim[[1]], Message[ROIMask::war]];
  roiSlice = Clip[ROI[[All, 2]], {1, maskdim[[1]]}];
  msk = 1 - 
      ImageData[
       Image[Graphics[Polygon[#], 
         PlotRange -> {{0, maskdim[[3]]}, {0, maskdim[[2]]}}], "Bit", 
        ColorSpace -> "Grayscale", 
        ImageSize -> maskdim[[2 ;; 3]]]] & /@ roiCor;
  MapIndexed[output[[#1]] = msk[[First[#2]]]; &, roiSlice];
  ];
 Return[output];]


(* ::Section:: *)
(*End Package*)


End[]

EndPackage[]
