-------------------------------------------------------------------------

/*
Name			: adBatchRemoveBackfaceCulling
Version			: 1.0.0
Description		: This script turns off the "backfaceCulling" for all objects in the scene
Type			: Batch
Date Created   	: 2015/02/17
Contact			: Ashish Dani ( contact@ashishdani.com )
Website			: www.ashishdani.com

UPDATES			: 	

*/


-------------------------------------------------------------------------



------------------------------------------------------------------

/*

adBatchRemoveBackfaceCulling

This script turns off the "backfaceCulling" for all objects in the scene

version 1.0.0

date       : 2015/02/17

*/

------------------------------------------------------------------


 


 


 

allObjectsInSceneBC = $*

for OBJbc in allObjectsInSceneBC do

(

                -- Turn off backfaceCulling

                OBJbc.backfacecull = off

)
