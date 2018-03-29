Fn LR_CaptureRenderAspectViewport  = 
    (
    local ViewCap=undefined         
    local cv = getViewSize()
    local ratio = undefined
 
           case of 
           ( 
            (cv.x > cv.y):(ratio = cv.y/cv.x)
            (cv.x = cv.y):(ratio = 1)           
            (cv.x < cv.y):(ratio = cv.x/cv.y)
       )
 
        VptDib =gw.getViewportDib();
                ViewCap = bitmap renderwidth renderheight color:white
                ViewportRatio = VptDib.width/VptDib.height as float
                RenderRatio = renderwidth/renderheight as float
 
                    case of
                    (
                    (ViewportRatio <= RenderRatio):(
                    CapturetoRenderHeightRatio =VptDib.width/RenderRatio as float
                    TopEdge = ((VptDib.Height-CapturetoRenderHeightRatio)/ 2.0) as integer
                    FullViewcap = bitmap vptdib.width CapturetoRenderHeightRatio color:white
                    pasteBitmap VptDib FullViewcap (box2 0 TopEdge VptDib.width VptDib.height) [0,0]
                    Copy FullViewcap ViewCap)
                    (ViewportRatio > RenderRatio):(
                    CapturetoRenderHeightRatio =VptDib.height*RenderRatio as float
                    LeftEdge = ((VptDib.width-CapturetoRenderHeightRatio)/ 2.0) as integer
                    FullViewcap = bitmap CapturetoRenderHeightRatio VptDib.height color:white
                    pasteBitmap VptDib FullViewcap (box2 LeftEdge 0 VptDib.width VptDib.height) [0,0]
                    Copy FullViewcap ViewCap)
                    default:()
                    )
                close VptDib
        gc()
 
                if viewcap != undefined then (setclipboardbitmap viewcap;close ViewCap;return true)else(return false)
    )
 
    tempbmp = LR_CaptureRenderAspectViewport()
    ResiMap = getclipboardbitmap()
	
	ResiMap.filename = ScreenPath + ((getfileNameFile maxFileName) + " " +ShotName) + ".jpg"
	save ResiMap
	Close ResiMap
	
	
-- 	print (ViewCap as string)