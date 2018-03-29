(
fn g_filter o = superclassof o == Geometryclass
fn find_intersection z_node node_to_z =
(
 local testRay = ray node_to_z.pos [0,0,-1]
 local nodeMaxZ = z_node.max.z
 testRay.pos.z = nodeMaxZ + 0.0001 * abs nodeMaxZ
 intersectRay z_node testRay
)
on isEnabled return selection.count > 0
on Execute do
(
 target_mesh = pickObject message:"Pick Target Surface:" filter:g_filter
 if isValidNode target_mesh then
 (
  undo "MoveToSurface" on
  (
   for i in selection do
   (
	   i.pivot.z = i.min.z
    int_point = find_intersection target_mesh i
    if int_point != undefined then i.pos = int_point.pos
		i.pivot.z = i.center.z
   )--end i loop
  )--end undo
 )--end if
)--end execute
)

