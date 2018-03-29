macroScript DisplayModeToggle category:"BDW" tooltip:"Toggle Display mode" 
(
displayColor.shaded = if (displayColor.shaded == #object) then #material else #object
)