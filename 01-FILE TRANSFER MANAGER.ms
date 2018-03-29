rollout _TFM "Transfer file"
(
	button _CF "Copy to Network" width:100 height:50 align:#center
	on _CF pressed do
	(::filein  @"\\CGISERVER\BDWRenderC\CGIResources\Scripts\BDW_Tools\ForUI\1-COPY TO NETWORK.ms")
	button _PF "Paste from Network" width:100 height:50 align:#center
	on _PF pressed do
	(ExportPath = getdir #downloads 
		EP = ExportPath + @"\paste.ms"
		::filein EP
	)
)
createdialog _TFM width:110 height:115