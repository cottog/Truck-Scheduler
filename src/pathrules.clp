;**************************************
;       PATH RULES
;**************************************


; This rule builds the ideal paths from each city to each other city
; It does so by going outward from each node and adding a new city, repeating this process until all paths from a node are exhausted,
; and then moving to a new node

(defrule find-path
	(path ?city1 ?city2&:(<> 0 (str-compare ?city1 ?city2)) ?distance1)
	(path ?city3&:(<> 0 (str-compare ?city1 ?city3))&:(<> 0 (str-compare ?city3 ?city2)) ?city1 ?distance2&:(> 16 (+ ?distance1 ?distance2)))
	(not (path ?city3 ?city2 ?dis&:(< ?dis (+ ?distance1 ?distance2))))
	(not (path ?city2 ?city3 ?dis&:(< ?dis (+ ?distance1 ?distance2))))
	(not (path ?city2 ?city3 ?dis&:(= ?dis (+ ?distance1 ?distance2))))
=>
	(assert (path ?city3 ?city2 =(+ ?distance1 ?distance2)))
)



;This rule gets rid of extra paths between two cities
;The "extra paths" in this case would be a path between two cities that is longer than another path 
;that is defined between those two cities

(defrule clean-dupes
	?y<-(path ?city1 ?city2 ?dist1)
	?z<-(path ?city1 ?city2 ?dist2&:(> ?dist2 ?dist1))
	(test (<> ?dist1 0))
	(test (<> ?dist2 0))
=>
	(retract ?z)
)



;This rule gets rid of other extra paths between two cities
;The "extra paths" in this case are paths that exist between two cities 
;That are opposite in direction and greater than or equal to another path between
;Those same two cities

(defrule clean-dupes-reverse
	?y<-(path ?city1 ?city2 ?dist1)
	?z<-(path ?city2 ?city1 ?dist2&:(>= ?dist2 ?dist1))
	(test (<> ?dist1 0))
	(test (<> ?dist2 0))
=>
	(retract ?z)
)
