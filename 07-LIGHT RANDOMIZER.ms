
-- Light Randomizer 1.5



rollout LON "Light Randomizer"
(
button grab "Add lights" width:175 height:40
	on grab pressed do
	(
-- 		--SEL = #()
-- 		if SEL.count == 0 then
-- 		(
			global SEL= selection as array 
-- 		)	
-- 	else 
-- 		(
-- 			SEL = SEL + selection
-- 	)	
-- 	print SEL
		)	

button addL "Append Lights" width:175
		on addL pressed do
		(
			SEL = SEL + selection
		)	
-- button remL "Remove Lights"
		
-- 		on remL pressed do
-- 		(
-- 			finditem SEL selection
-- 			print SEL
-- 		)
			
			
				

button LR "On/Off" width:175 height:40

	on LR pressed do
		(
	for i in SEL do
(      
	R = Random 0 200
		i  .target_distance = R
	)
	
for o in SEL do
(
	if o.target_distance <= 100 then
		o.on = false
	else
	o.on = true
)

for b in SEL do
(
	
	  b.target_distance = 200)
  )
  
spinner MinI "Min : " align:#center across:2 offset:[0,0] range:[0,1000,1.5]
spinner MaxI "Max : " align:#center offset:[0,0] range:[0,1000,5]
  
  
  button RANm "Random Inten" width:175 height:40 align:#center
  on RANm pressed do
	  for c in SEl do
	  (
		x = random MinI.value MaxI.value
		c.multiplier = x
		  )
	colorpicker ColorA "Color A" align:#left color:[255,  255, 255] across:2--width:175
		   
	colorpicker ColorB "Color B" align:#left color:[255, 255, 255] --width:175
		 
			  
	button Cran "Color Rand" width:175 height:40 align:#center
		  on Cran pressed do
		  ( 
			  for d in SEL do
			  (
				AC = ColorA.color
				AB = ColorB.color
-- 				CC = ColorC.color
-- 				RN = random 
				d.color = random AC AB
				  
				  )
			  
			  )
  
  )
  createdialog LON width:200 height:265  
  