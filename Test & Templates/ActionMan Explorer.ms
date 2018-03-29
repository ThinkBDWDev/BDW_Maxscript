for i = 1 to actionMan.numActionTables-1 do 
(
	atbl = actionMan.getActionTable i
	format "% ID:% Name:'%' ContextID:% ContextName:'%' NumActionItems:%\n" i atbl.id atbl.name atbl.contextID atbl.contextName atbl.numActionItems
	for j = 1 to atbl.numActionItems do
	(
		aitm = atbl.getActionItem j
		aitm.getDescription &desc 
		aitm.getCategory &cat
		aitm.getButtonText &btn
		aitm.getMenuText &mnu
		hasicon = aitm.hasIcon()
		if hasicon then
		(
			aitm.getIconFileName &iconfile 
			iconfile = filenamefrompath iconfile 
			iconindex = aitm.getIconIndex()
			format "\t% ID:% Desc:'%' Cat:'%' BtnTxt:'%' MnuTxt:'%' Icon:[%,%] \n" j aitm.id desc cat btn mnu iconfile iconindex
		)
		else
			format "\t% ID:% Desc:'%' Cat:'%' BtnTxt:'%' MnuTxt:'%'\n" j aitm.id desc cat btn mnu 
	)
)