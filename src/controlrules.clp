;**************************************
;       CONTROL RULES
;**************************************

;These rules are the engine that drives the package delivery system



;This rule is here to ensure that the simulation doesn't run forever, but it doesn't usually work. 
;I don't want to try and use salience to force it to work, if I even could
(defrule break-loops
	(global-clock ?x&:(>= ?x 500))
=>
	(halt)
)


;*********************************************
;       PACKAGE DELIVERY RULES (THE MEAT)
;*********************************************


;This rule issues orders to trucks for packages to be picked up
;The list of undelivered packages is checked, and packages whose order arrival time
;are equal to the time specified by the global clock are marked for delivery
;The "please-get" fact is in effect asking a truck to come to a particular city and get the specified package
(defrule issue-order
	(global-clock ?x)
	?z<-(package (number ?num)(pickup ?pickupcity)(size ?size)
		(status ?stat)(arrival-time ?arrival))
	(test (= ?x ?arrival))
	(test (= 0 (str-compare ?stat unordered)))
=>
	(assert (please-get ?num ?pickupcity ?size))
	(modify ?z(status waiting))
)




;This rule facilitates the picking up of a package that has been marked for delivery
;The "please-get" fact is checked for a city and then a truck from Orlando is assigned to come to the city and get the truck
;This version of the KBS aims to use trucks from cities other than Orlando, so this function will stop the clock
;until it can be determined that either a different truck is better suited to the task or this truck from Orlando is best
(defrule receive-order
	?z<-(please-get ?packnum ?dest ?size)
	?y<-(truck (capacity ?x)(number ?foo)(location ?loca)(destination ?home)(action idle)
		(time-to-dest ?time)(time-busy ?busytime)(totalSizes ?totsize)
		(non-deliver-time ?ndtime))
	?wesker<-(truck (capacity ?capacity)(number ?bar&:(<> ?bar ?foo))(location ?location)(destination ?destin)(action idle)
		(time-to-dest ?dtime)(time-busy ?btime)(totalSizes ?totalsize))
	(test (>= ?x ?size))
	(test (>= ?capacity ?size))
	(or (path ?loca ?dest ?dist)
		(path ?dest ?loca ?dist))
	(not (or (path ?location ?dest ?distance&:(> ?dist ?distance))
		(path ?dest ?location ?distance&:(> ?dist ?distance))))
=>
	(retract ?z)
	(modify ?y(action picking-up)(time-to-dest ?dist)(destination ?dest)
		(time-busy =(+ ?busytime ?dist))(non-deliver-time =(+ ?ndtime ?dist))
		(totalSizes =(+ ?totsize ?size)))
	(printout t "Truck " ?foo " is leaving from " ?loca " for package " ?packnum crlf)
)

	
;This rule accounts for the packages that can only fit in one truck
;It works the same as the other get-pakage, but makes sure that only one truck can fit the package in question
(defrule receive-order-too-large
	?z<-(please-get ?packnum ?dest ?size)
	?y<-(truck (capacity ?x)(number ?foo)(location ?loca)(destination ?home)(action idle)
		(time-to-dest ?time)(time-busy ?busytime)(totalSizes ?totsize)
		(non-deliver-time ?ndtime))
	(not (truck (capacity ?capacity&:(> ?capacity ?size))(number ?bar&:(<> ?bar ?foo))(location ?location)(destination ?destin)(action idle)
		(time-to-dest ?dtime)(time-busy ?btime)(totalSizes ?totalsize)))
	(test (>= ?x ?size))
	(or (path ?loca ?dest ?dist)
		(path ?dest ?loca ?dist))
=>
	(retract ?z)
	(modify ?y(action picking-up)(time-to-dest ?dist)(destination ?dest)
		(time-busy =(+ ?busytime ?dist))(non-deliver-time =(+ ?ndtime ?dist))
		(totalSizes =(+ ?totsize ?size)))
	(printout t "Truck " ?foo " is leaving from " ?loca " for package " ?packnum crlf)
)

	
	
	
;This rule essentially puts the package into the truck
;The paths are parsed, searching for a length between the pickup city and the destination city
;This length is then set in the truck's time-to-dest field, which is decremented as the clock updates,
;counting down until the new city is reached
(defrule get-package
	(global-clock ?x)
	?y<-(truck (capacity ?cap)(package-held none)(destination ?pickup-city)
		(action picking-up)(time-to-dest ?time)(time-busy ?busytime)
		(deliver-time ?dtime))
	?z<-(package (number ?packnum)(pickup ?pickup-city)(dropoff ?dest)(size ?size)(status waiting)(pickup-time ?put))
	(test (= ?time 0))
	(or (path ?pickup-city ?dest ?distance)
		(path ?dest ?pickup-city ?distance))
=>
	(modify ?y(capacity =(- ?cap ?size))(package-held ?packnum)
		(destination ?dest)(action delivering)(time-to-dest ?distance)
		(time-busy =(+ ?busytime ?distance))(deliver-time =(+ ?dtime ?distance)))
	(modify ?z(status received)(pickup-time ?x))
)





;This facilitates dropping the package off at its destination
;The previous version of this rule set the truck on a course back to Orlando, but that will not be done this time around.
;The truck will sit where it dropped off the package and wait for a new one to arrive.
(defrule drop-package
	(global-clock ?x)
	?y<-(truck (number ?foo)(capacity ?cap)(package-held ?packnum)
		(destination ?dropoff-city)(action delivering)
		(time-to-dest ?time)(time-busy ?busytime)(location ?loca)
		(non-deliver-time ?ndtime)(packages-transported $?packages))
	?z<-(package (number ?packnum)(size ?size)(status received)(deliver-time ?det))
	(test (= ?time 0))
=>
	(modify ?y(capacity =(+ ?cap ?size))(package-held none)(destination none)(action idle)(time-to-dest 0)(location ?dropoff-city)
		(packages-transported $?packages ?packnum))
	(modify ?z(status delivered)(deliver-time ?x))
	(printout t "Package " ?packnum " delivered to " ?dropoff-city "." "Truck " ?foo " went idle at " ?dropoff-city  crlf)
)

;NOTE TO SELF, LOOK AT OLD CODE IF SOMETHING TO DO WITH GOING IDLE IS MESSED UP

;**************************************
;       GLOBAL CLOCK RULES
;**************************************

;This rule tells a truck to update its internal clock after the global clock has been updated
;This helps a truck know how long it has been travelling towards a particular city
(defrule update-truck-clock
	(global-clock ?x)
	?y<-(truck (clock ?truck)(time-to-dest ?desttime))
	(test (> ?x ?truck))
=>
	(bind ?f (- ?x ?truck))
	(modify ?y(clock =(+ ?truck ?f))(time-to-dest =(- ?desttime ?f)))
)




;This rule stops the clock once all trucks are idle and all packages have been delivered
;This starts the next phase of the program, which generates and outputs the package/truck reports
;This rule also asserts the package and truck counters, which are used to ensure that the reports are printed in a meaningful order
(defrule stop-clock
	?x<-(update yes)
	(not (package (status ?y&:(<> 0 (str-compare ?y delivered)))))
	(not (truck (action ?z&:(<> 0 (str-compare ?z idle)))))
	(packs ?paa)
	(trucks ?trr)
=>
	(retract ?x)
	(assert (total-late 0 counter 0))
	(assert (truck-counter ?trr))
	(assert (pack-counter ?paa))
)




;This rule updates the global clock, once all trucks have been updated and packages have come out of any transient states they might be in
;It increments the clock by one, but any increment could really be used. 
;Trucks all update their clock based on the difference between their clock and the global clock's values
(defrule update-clock
	(update yes)
	(not (stop-clock ?ye ?yo))
	?z<-(global-clock ?x)
=>
	(retract ?z)
	(assert (global-clock =(+ ?x 1)))
)



;**************************************
;       RECORD-KEEPING RULES
;**************************************

;This rule makes the truck records. It calculates the percentages needed, such as percentage of time spent busy and all that other stuff
;The 1.0 in the divisions down there is to ensure that the output is a float, as the two numbers being divided are integers
(defrule make-records
	(not (update ?ggg))
	?foo<-(truck-counter ?tcount)
	?x<-(truck (number ?trucknum&:(= ?trucknum ?tcount))(wait-time ?wtime)(time-busy ?btime)
		(busy-percent ?busyper)(packages-transported $?packages)(clock ?clock)
		(totalSizes ?size)(deliver-time ?deltime)(non-deliver-time ?ndtime)(busy-deliver-percent ?bdper)(record-made false))		
=>
	(modify ?x(wait-time =(- ?clock ?btime))(busy-percent =(/ ?btime ?clock 1.0))(busy-deliver-percent =(/ ?deltime ?btime 1.0))(record-made true))
	(retract ?foo)
	(assert (truck-counter =(- ?tcount 1)))

)		





;This rule prints the truck records, outputting information for each of them in formatted lines.
(defrule print-truck-records
	(not (update ?gg))
	?foo<-(truck-counter ?tcount)
	?x<-(truck (number ?trucknum&:(= ?trucknum (+ ?tcount 1)))(capacity ?cap)(wait-time ?wtime)(time-busy ?btime)
		(busy-percent ?busyper)(packages-transported $?packages)
		(totalSizes ?size)(non-deliver-time ?ndtime)(busy-deliver-percent ?bdper))
=>
	(bind ?len (length $?packages))
	(bind ?fill (* 100 (/ ?size (* ?cap (length $?packages)))))
	(format t "Truck %4d | wait time  %4d | busy time %4d | percent busy %7.3f | packages delivered %4d | non-delivery travel time %4d | percent busy time spent delivering %7.3f | avg. percent of truck occupied %7.3f %n" ?trucknum ?wtime ?btime (* ?busyper 100) ?len ?ndtime (* 100 ?bdper) ?fill)
	(retract ?foo)
	(assert (truck-counter =(+ ?tcount 1)))
)




;This rule computes some relevant info for the package records
;This rule calculates the wait time and lateness for each package, setting a negative lateness for packages that arrived ahead of schedule (and zero for those on time)
;This rule also marks packages as having been modified by the rule, but I don't know if its necessary
(defrule make-pack-records
	(not (update ?ttt))
	?y<-(pack-counter ?pcount)
	?z<-(package (number ?pnum&:(= ?pnum ?pcount))(arrival-time ?atime)(pickup-time ?ptime)(wait-time ?wtime)(deliver-time ?devtime)
		(expected-time ?extime)(record-made ?rec&:(= ?rec 0)))
=>
	(modify ?z(wait-time =(- ?ptime ?atime))(lateness =(- ?devtime ?extime))(record-made 1))
	(retract ?y)
	(assert (pack-counter =(- ?pcount 1)))
)




;This rule prints package records for late packages, and has been formatted rather nicely, in my opinion.
(defrule print-pack-records-late
	(not (update ?ttt))
	?bar<-(total-late ?later counter ?coo)
	?foo<-(pack-counter ?pcount)
	?y<-(package (number ?pnum&:(= ?pnum (+ ?pcount 1)))(pickup-time ?putime)(wait-time ?wtime)(deliver-time ?devtime)(record-made ?rec&:(= ?rec 1))(lateness ?late&:(> ?late 0))(record-printed ?printed&:(= ?printed 0)))
=>
	(modify ?y(record-printed 1))
	(format t "Package %4d | wait time %4d | pick-up time %4d | delivery time %4d | lateness %d %n" ?pnum ?wtime ?putime ?devtime ?late )
	(retract ?foo)
	(retract ?bar)
	(assert (pack-counter =(+ ?pcount 1)))
	(assert (total-late =(+ ?later ?late) counter =(+ ?coo 1)))
)	




;This rule outputs the package records for packages that arrived on time
;Whereas late packages have an actual value for their "lateness" column, these packages all have zero lateness
(defrule print-pack-records
	(not (update ?ttt))
	?foo<-(pack-counter ?pcount)
	?y<-(package (number ?pnum&:(= ?pnum (+ ?pcount 1)))(pickup-time ?putime)(wait-time ?wtime)(deliver-time ?devtime)(record-made ?rec&:(= ?rec 1))(lateness ?late&:(<= ?late 0))(record-printed ?printed&:(= ?printed 0)))
=>
	(modify ?y(record-printed 1))
	(format t "Package %4d | wait time %4d | pick-up time %4d | delivery time %4d | lateness 0 %n" ?pnum ?wtime ?putime ?devtime)
	(retract ?foo)
	(assert (pack-counter =(+ ?pcount 1)))
)	

(defrule print-pack-averages
	(not (package (record-printed ?printed&:(= ?printed 0))))
	(total-late ?total counter ?count)
	(pack-counter ?pcount)
=>
	(bind ?f (/ ?total ?count))
	(bind ?g (/ ?total ?pcount))
	(format t "Average lateness for late packages %7.4f | Average lateness for all packages %7.4f %n%n%n" ?f ?g)
)

	