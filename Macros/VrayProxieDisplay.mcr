macroScript ProxDisplay category:"BDW" buttonText:"Vrayproxy Display" tooltip:"Vrayproxy Display"
(
for o in objects where ClassOf o == Vrayproxy do o.display= 3
)