(
	--------------------------------------------------------
	-- SubmitMaxToDeadline Sanity Check for Max (DotNet Version)
	-- Deadline submission profiling script for 3dsmax
	-- Copyright (c) 2004-2014 by Thinkbox Software Inc
	-- All rights reserved.
	--------------------------------------------------------
	-- Code by Bobo:
	-- 2011/11/09 - Made the Dialog Resizable
	-- 2006/12/04 - DotNet version for Max 9
	-- 2006/03/30 - Split Functions, Repair Functions and Definitions to Public and Private. 
	-- 2005/06/27 - Added checks for output file containing PROJECTS and mismatching scene and output PREFIX
	-- 2004/09/30 - Fixed Brazil Camera errors, added Internal check for rendering sequences to Y:
	-- 2004/06/16 - Checkboxes for skipping single tests, status lamp for passed/failed, sticky screen position, 
	--				Added check for Untitled file name,
	-- 				Changed SanityCheck function name to SMTD_PerformSanityCheck
	-- 2004/06/15 - Fixed listview bg colot to work with dark UI scheme, added tests for MOV files, trailing numbers, added status report line between the listviews.
	-- 2004/06/15 - Changed to ListView ActiveX control. Added tests and fixes for render time and path
	-- 2004/06/11 - Initial version. Checks for empty scene, camera view, mpass mblur and mblur duration implemented.
	--------------------------------------------------------
	
	global SMTD_PerformSanityCheck 

	global SMTD_SanityCheck_errorReportRollout
	global SMTD_SanityCheck_actionsArray = #()
	global SMTD_ErrorMessagesArray = #()	
	global SMTD_SanityCheck_errorReportIndexArray = #()

	global SMTD_SanityCheckFunctions
	global SMTD_RepairFunctions 
	global SMTD_SanityChecksToPerform

	global SMTD_Private_SanityCheckFunctions
	global SMTD_Private_RepairFunctions 
	global SMTD_Private_SanityChecksToPerform
	
	if SMTD_General_SanityChecksToPerform == undefined do SMTD_General_SanityChecksToPerform = #()
	if SMTD_Private_SanityChecksToPerform == undefined do SMTD_Private_SanityChecksToPerform = #()
	
	join SMTD_SanityChecksToPerform SMTD_Private_SanityChecksToPerform 
	
	try(destroyDialog SMTD_SanityCheck_errorReportRollout)catch()
	
	rollout SMTD_SanityCheck_errorReportRollout "The Sanity Check Found The Following Problems:"
	(
		local disableEvents = true
		fn initListView lv theType =
		(
			lv.Items.clear()
			lv.gridLines = true
			lv.View = (dotNetClass "System.Windows.Forms.View").Details
			lv.backColor = (dotNetClass "System.Drawing.Color").fromARGB 221 221 225
			lv.FullRowSelect = true
			lv.hideSelection = true
			
			case theType of
			(
				1:
				(
					lv.checkboxes = true
					lv.Columns.add "Error Type" 90
					lv.Columns.add "Error Description" 500
					lv.ForeColor = (dotNetClass "System.Drawing.Color").Red
					lv.multiSelect = false
				)
				2:
				(
					lv.checkboxes = false
					lv.Columns.add "Type" 70
					lv.Columns.add "Message" 520
					lv.ForeColor = (dotNetClass "System.Drawing.Color").DarkBlue
					lv.multiSelect = true
				)
			)		
		)	

		fn fillInSpreadSheet lv theArray =
		(
			lv.Items.clear()
			total_count = theArray.count
			theRange = #()
			for i = 1 to total_count  do
			(
				li = dotNetObject "System.Windows.Forms.ListViewItem" theArray[i][1][2]
				try(li.checked = SMTD_SanityChecksToPerform[(theArray[i][3])][5])catch()
				li.forecolor = (dotNetClass "System.Drawing.Color").fromARGB theArray[i][1][1].b theArray[i][1][1].g theArray[i][1][1].r
				--li.bold= theArray[i][1][3]
				
				for j = 2 to theArray[i].count do
				(
					li2 = li.SubItems.add (theArray[i][j] as string)
					li2.forecolor = (dotNetClass "System.Drawing.Color").fromARGB theArray[i][1][1].b theArray[i][1][1].g theArray[i][1][1].r
					--li2.bold= theArray[i][1][3]					
				)	
				append theRange li
			)
			lv.Items.AddRange theRange
			for i = 1 to total_count do
				lv.items.item[i-1].forecolor = (dotNetClass "System.Drawing.Color").fromARGB theArray[i][1][1].b theArray[i][1][1].g theArray[i][1][1].r
		)	
		
		fn getSelection lv =
		(
			for i in 0 to lv.Items.count-1 do
			(
				li = lv.Items.item[i]
				if li.selected do return (i+1)
			)
			0
		)
		
		fn setSelection lv index =
		(
			try(lv.Items[index].selected = true)catch()
		)	
		
		fn CollectCheckedStates lv =
		(
			for i in 0 to lv.Items.count-1 do
			(
				try
				(
					li = lv.Items.item[i]
					SMTD_SanityChecksToPerform[SMTD_ErrorMessagesArray[i+1][3]][5] = li.checked 
				)catch()	
			)
		)
		
		
------------------------
--UI		
------------------------		

		label lbl_info "Right-click Error to attempt fix. Uncheck to ignore non-fatal errors and warnings." align:#left
		dotNetControl lv_errors "System.Windows.Forms.ListView" width:595 height:150 align:#center offset:[0,0]
		label lb_errors align:#left across:2 
		progressbar prb_status value:100 color:(color 0 255 0) align:#right height:16 width:50 offset:[0,-1]
		dotNetControl lv_actions "System.Windows.Forms.ListView" width:595 height:150 align:#center offset:[0,0]
		fn CollectCheckedAndTest =
		(
			local st = timestamp()
			CollectCheckedStates lv_errors
			local result = SMTD_PerformSanityCheck()	
			try(SMTD_MainRollout.Ui_report (">Sanity Check took " + ((timestamp()-st)/1000.0) as string + " sec." ))catch()
			if result then
				try(SMTD_MainRollout.Ui_report (">+The Scene PASSED the Sanity Check."))catch()
			else
				try(SMTD_MainRollout.Ui_report (">--The Scene DID NOT PASS the Sanity Check!"))catch()
			result		
		)
		fn log_action thePrefix theColor theBold theMessage =
		(
			insertItem #(#(theColor, thePrefix, theBold ),theMessage) SMTD_SanityCheck_actionsArray 1
			fillInSpreadSheet lv_actions SMTD_SanityCheck_actionsArray
			--setSelection lv_actions 1
		)

		on lv_errors MouseClick itm do 
		(
			if itm.Button.Equals itm.Button.Right then
			(
				theItem= getSelection lv_errors
				if theItem> 0 then
				(
					SMTD_SanityChecksToPerform[SMTD_SanityCheck_errorReportIndexArray[theItem]][4]()
					CollectCheckedAndTest()
				)
			)	
		)
		
		on lv_actions MouseClick itm do
		(
			if itm.Button.Equals itm.Button.Right then
			(
				text = ""
				for i in 0 to lv_actions.Items.count-1 do
				(
					li = lv_actions.Items.item[i]
					if li.selected then
						text = text + li.SubItems.item[0].Text + ": " + li.SubItems.item[1].Text + "\n"
				)
				setclipboardText text
				try(SMTD_MainRollout.Ui_report ("Copied item(s) to clipboard."))catch()
			)
		)
	
		on lv_errors ItemChecked arg do 
		(
			if not disableEvents then
			(
				CollectCheckedStates lv_errors
				SMTD_PerformSanityCheck updateOnly:true
			)
		)
		on lv_errors DoubleClick do CollectCheckedAndTest()
		on lv_actions DoubleClick do CollectCheckedAndTest()
		
		on SMTD_SanityCheck_errorReportRollout resized size do
		(
			if size.x < 600 do size.x = 600 
			if size.y < 350 do size.y = 350
			SMTD_SanityCheck_errorReportRollout.width = size.x
			SMTD_SanityCheck_errorReportRollout.height = size.y
				
			
			lv_errors.width = lv_actions.width = size.x-6
			lv_errors.height = lv_actions.height = size.y/2 - 25
			lv_errors.pos = [4,23]
			lb_errors.pos = [4,size.y/2+2]
			lv_actions.pos = [4,size.y/2+22]
			prb_status.pos = [size.x-55, size.y/2+2]
			prb_status.color = prb_status.color
			setIniSetting (GetDir #plugcfg + "\\SMTDSanityCheck.ini") "Dialog" "Size" (size as string)
		)
		
		on SMTD_SanityCheck_errorReportRollout lbuttondown pnt do CollectCheckedAndTest()			
		on SMTD_SanityCheck_errorReportRollout rbuttondown pnt do CollectCheckedAndTest()			
		
		on SMTD_SanityCheck_errorReportRollout moved pnt do 
			setIniSetting (GetDir #plugcfg + "\\SMTDSanityCheck.ini") "Dialog" "Position" (pnt as string)
			
	)		
	
-------------------------------------------
--MAIN FUNCTION
-------------------------------------------
	fn SMTD_PerformSanityCheck updateOnly:false=
	(	
		SMTD_ErrorMessagesArray = #()
		local fatalCount = 0
		local fixCount = 0
		local warnCount = 0
		local totalCount = 0
		
		SMTD_SanityCheck_errorReportIndexArray = #()		
		if renderSceneDialog.isOpen() do renderSceneDialog.commit()
		SMTD_SanityCheck_errorReportRollout.prb_status.color = yellow
		for c = 1 to SMTD_SanityChecksToPerform.count do
		(
			SMTD_SanityCheck_errorReportRollout.prb_status.value = 100.0 * c / SMTD_SanityChecksToPerform.count
			if not ((SMTD_SanityChecksToPerform[c][1])()) do 
			(	
				append SMTD_SanityCheck_errorReportIndexArray c
				error_prefix = ""
				case SMTD_SanityChecksToPerform[c][2] of
				(
					#fail: 
					( 
						error_prefix = "FATAL" 
						error_color = color 0 0 255
						error_bold = true
						fatalCount += 1
						totalCount += 1
					)	
					#fix: 
					(
						error_prefix = "Can Be Fixed"
						error_color = color 0 100 0
						error_bold = false
						fixCount += 1
						if SMTD_SanityChecksToPerform[c][5] do totalCount +=1
					)	
					#warn:  
					(
						error_prefix = "Warning"
						error_color = color 100 0 0 
						error_bold = false
						warnCount += 1
					)	
				)
				append SMTD_errorMessagesArray ( #(#(error_color, error_prefix, error_bold), SMTD_SanityChecksToPerform[c][3], c ))
			)	
		)	
		if SMTD_SanityCheck_errorReportIndexArray.count > 0 then
		(
			SMTD_SanityCheck_errorReportRollout.disableEvents = true		
			if not SMTD_SanityCheck_errorReportRollout.Open do 
			(
				local thePos = execute (getIniSetting (GetDir #plugcfg + "\\SMTDSanityCheck.ini") "Dialog" "Position" )
				local theSize = execute (getIniSetting (GetDir #plugcfg + "\\SMTDSanityCheck.ini") "Dialog" "Size" )
				
				if theSize == OK do 
				(
					theSize = [600,350]
				)				
				if thePos != OK then 
				(
					if thePos.x < 0 do thePos.x = 0
					if thePos.y < 0 do thePos.y = 0
					if thePos.x > sysinfo.desktopSize.x-theSize.x do thePos.x = sysinfo.desktopSize.x-theSize.x 
					if thePos.y > sysinfo.desktopSize.y-theSize.y do thePos.y = sysinfo.desktopSize.y-theSize.y 
						
					createDialog SMTD_SanityCheck_errorReportRollout theSize.x theSize.y thePos.x thePos.y style:#(#style_resizing, #style_titlebar, #style_border, #style_sysmenu, #style_maximizebox)
				)
				else
					createDialog SMTD_SanityCheck_errorReportRollout theSize.x theSize.y  style:#(#style_resizing, #style_titlebar, #style_border, #style_sysmenu, #style_maximizebox)
				
				SMTD_SanityCheck_errorReportRollout.resized theSize
				--SMTD_SanityCheck_errorReportRollout.CollectCheckedAndTest()
				
				SMTD_SanityCheck_errorReportRollout.initListView SMTD_SanityCheck_errorReportRollout.lv_errors 1
				SMTD_SanityCheck_actionsArray = #()
				SMTD_SanityCheck_errorReportRollout.log_action "Info" (color 155 0 0) false "Initializing Sanity Check..."
				SMTD_SanityCheck_errorReportRollout.initListView SMTD_SanityCheck_errorReportRollout.lv_actions 2
				SMTD_SanityCheck_errorReportRollout.log_action "Info" (color 155 0 0) false "Done."
			)	
			if not updateOnly do
			(
				SMTD_SanityCheck_errorReportRollout.fillInSpreadSheet SMTD_SanityCheck_errorReportRollout.lv_errors SMTD_errorMessagesArray
				SMTD_SanityCheck_errorReportRollout.fillInSpreadSheet SMTD_SanityCheck_errorReportRollout.lv_actions SMTD_SanityCheck_actionsArray
			)	
			txt = ("Detected " + SMTD_SanityCheck_errorReportIndexArray.count as string + " potential problems: "+fatalCount as string +" Fatal, "+ fixCount as string +" Can Be Fixed, ")
			if warnCount == 1 then
				txt += "1 Warning." 
			else
				txt += warnCount as string +" Warnings." 
			txt += " Right-click items to copy to clipboard."
			
			try(
				if SMTD_MainRollout.dnc_report.items.Item[SMTD_MainRollout.dnc_report.items.count-1].SubItems.Item[1].Text != ">>"+txt do
					SMTD_MainRollout.Ui_report (">>"+txt)
			)catch()				
				
				
			if totalCount == 0 then 
			(
				SMTD_SanityCheck_errorReportRollout.prb_status.color = (color 0 255 0) 
			)	
			else 
			(
				SMTD_SanityCheck_errorReportRollout.prb_status.color = (color 255 0 0) 
			)	
			SMTD_SanityCheck_errorReportRollout.prb_status.value = 100
			SMTD_SanityCheck_errorReportRollout.lb_errors.text = txt
			SMTD_SanityCheck_errorReportRollout.disableEvents = false
			totalCount == 0 
		)
		else
		(	
			txt = ("Detected " + SMTD_SanityCheck_errorReportIndexArray.count as string + " potential problems: "+fatalCount as string +" Fatal, "+ fixCount as string +" Can Be Fixed, ")
			if warnCount == 1 then
				txt += "1 Warning." 
			else
				txt += warnCount as string +" Warnings." 
			try
			(
				SMTD_MainRollout.Ui_report (">>"+txt)
			)catch()		
			destroyDialog SMTD_SanityCheck_errorReportRollout
			true	
		)	
	)
)
