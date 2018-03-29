---------------------------------------------------------------------
/*
-- adTools.mcr
-- By Ashish Dani (contact@ashishdani.com) www.ashishdani.com
-- v 1.0.0
-- UPDATED	: 
			
-- Tested using 3Ds Max 2015
-- THIS IS A FREEWARE.
-- Thanks to everyone for the great support :)
*/
---------------------------------------------------------------------
---------------------------------------------------------------------

(

	-------------------------------------------------------------------------------------------------------
	-------------adBackfaceCulling----------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------
	macroscript adBackfaceCulling category:"ADaniTools" tooltip:"adBackfaceCulling"
	(
		Include "$scripts/ADaniTools/adBackfaceCulling.ms"
		on execute do adBackfaceCullingDefaults()
	)		-- adBackfaceCulling ENDS
	-------------------------------------------------------------------------------------------------------


	-------------------------------------------------------------------------------------------------------
	-------------adBitmapUtilities----------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------
	macroscript adBitmapUtilities category:"ADaniTools" tooltip:"adBitmapUtilities"
	(
		Include "$scripts/ADaniTools/adBitmapUtilities.ms"
		on execute do adBitmapUtilitiesDefaults()
	)		-- adBitmapUtilities ENDS
	-------------------------------------------------------------------------------------------------------
	
	
	-------------------------------------------------------------------------------------------------------
	-------------adCollapseAllModifiers-------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------		
	macroscript adCollapseAllModifiers category:"ADaniTools" tooltip:"adCollapseAllModifiers"
	(
		Include "$scripts/ADaniTools/adCollapseAllModifiers.ms"
		on execute do adCollapseModDefaults()
	)		-- adCollapseAllModifiers ENDS
	-------------------------------------------------------------------------------------------------------		
	
	
	
	-------------------------------------------------------------------------------------------------------
	-------------adDetachBasedOnfaceID-------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------		
	macroscript adDetachBasedOnfaceID category:"ADaniTools" tooltip:"adDetachBasedOnfaceID"
	(
		Include "$scripts/ADaniTools/adDetachBasedOnfaceID.ms"
		on execute do adDetachBasedOnfaceIdDefaults()
	)		-- adDetachBasedOnfaceID ENDS
	-------------------------------------------------------------------------------------------------------		
	
	
	-------------------------------------------------------------------------------------------------------
	-------------adGroupUtilities-------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------		
	macroscript adGroupUtilities category:"ADaniTools" tooltip:"adGroupUtilities"
	(
		Include "$scripts/ADaniTools/adGroupUtilities.ms"
		on execute do adGroupUtilitiesDefaults()
	)		-- adGroupUtilities ENDS
	-------------------------------------------------------------------------------------------------------		
	
	
	-------------------------------------------------------------------------------------------------------
	-------------adMatIDMinMax-----------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------		
	macroscript adMatIDMinMax category:"ADaniTools" tooltip:"adMatIDMinMax"
	(
		Include "$scripts/ADaniTools/adMatIDMinMax.ms"
		on execute do adMatIDMinMaxDefaults()
	)		-- adMatIDMinMax ENDS
	-------------------------------------------------------------------------------------------------------	
	
	
	
	-------------------------------------------------------------------------------------------------------
	-------------adSelectBySceneMaterial-------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------	
	macroscript adSelectBySceneMaterial category:"ADaniTools" tooltip:"adSelectBySceneMaterial"
	(
		Include "$scripts/ADaniTools/adSelectBySceneMaterial.ms"
		on execute do adSelectBySceneMaterialDefaults()
	)		-- adSelectBySceneMaterial ENDS
	-------------------------------------------------------------------------------------------------------	

	

	

	-------------------------------------------------------------------------------------------------------
	-------------adSetSystemGammaValues--------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------
	macroscript adSetSystemGammaValues category:"ADaniTools" tooltip:"adSetSystemGammaValues"
	(
		Include "$scripts/ADaniTools/adSetSystemGammaValues.ms"
		on execute do adSetSystemGammaValuesDefaults()
	)		-- adSetSystemGammaValues ENDS
	-------------------------------------------------------------------------------------------------------	
	
		
			
	
	

	-------------------------------------------------------------------------------------------------------
	-------------adTurboSubDiv---------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------		
	macroscript adTurboSubDiv category:"ADaniTools" tooltip:"adTurboSubDiv"
	(
		Include "$scripts/ADaniTools/adTurboSubDiv.ms"
		on execute do adTurboSubDivDefaults()
	)
	-------------------------------------------------------------------------------------------------------

	-------------------------------------------------------------------------------------------------------
	-------------adSetVRaySilentMode--------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------
	macroscript adSetVRaySilentMode category:"ADaniTools" tooltip:"adSetVRaySilentMode"
	(
		Include "$scripts/ADaniTools/adSetVRaySilentMode.ms"
		on execute do adSetVRaySilentModeDefaults()
	)		-- adSetVRaySilentMode ENDS
	-------------------------------------------------------------------------------------------------------
	
	
	
	-------------------------------------------------------------------------------------------------------
	-------------adXFrogLeafSHDEditor--------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------
	macroscript adXFrogLeafSHDEditor category:"ADaniTools" tooltip:"adXFrogLeafSHDEditor"
	(
		Include "$scripts/ADaniTools/adXFrogLeafSHDEditor.ms"
		on execute do adXFrogLeafSHDEditorDefaults()
	)		-- adXFRLeafSHDEditor ENDS
	-------------------------------------------------------------------------------------------------------	
	
	
	-------------------------------------------------------------------------------------------------------
	-------------adXFrogPetalSHDEditor--------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------------
	macroscript adXFrogPetalSHDEditor category:"ADaniTools" tooltip:"adXFrogPetalSHDEditor"
	(
		Include "$scripts/ADaniTools/adXFrogPetalSHDEditor.ms"
		on execute do adXFrogPetalSHDEditorDefaults()
	)		-- adXFrogPetalSHDEditor ENDS
	-------------------------------------------------------------------------------------------------------	
	
	
)			-- PRIMARY FUNCTION ENDS






