;**************************************
;       FACTS -- DATA SET 2
;**************************************

;The map is defined in terms of the roads between each city
;The roads are defined by specifying the city on either end, followed by the length of the road
;The paths are then used to construct the ideal path from each node to all possible nodes it connects to, 
;by seeing what cities are joined to it and its neighbors

(deffacts map-init
	(update yes)
	(global-clock 0)
	(home-base Orlando)
	(trucks 10)
	(packs 50)
	(path Key-West Miami 3)
	(path Miami Key-West 3)
	(path Miami West-Palm 2)
	(path West-Palm Miami 2)
	(path West-Palm Ft-Myers 3)
	(path West-Palm Orlando 3)
	(path West-Palm St-Augustine 3)
	(path Ft-Myers Tampa 2)
	(path Ft-Myers West-Palm 3)
	(path Tampa Ft-Myers 2)
	(path Tampa Ocala 2)
	(path Tampa Orlando 1)
	(path Ocala Tampa 2)
	(path Ocala Gainesville 1)
	(path Ocala Orlando 1)
	(path Gainesville Ocala 1)
	(path Gainesville Lake-City 1)
	(path Gainesville St-Augustine 1)
	(path Lake-City Gainesville 1)
	(path Lake-City Tallahassee 2)
	(path Lake-City Jacksonville 1)
	(path Tallahassee Lake-City 2)
	(path Jacksonville Lake-City 1)
	(path Jacksonville St-Augustine 1)
	(path St-Augustine Jacksonville 1)
	(path St-Augustine West-Palm 3)
	(path St-Augustine Orlando 2)
	(path St-Augustine Gainesville 1)
	(path Orlando West-Palm 3)
	(path Orlando Tampa 1)
	(path Orlando Ocala 1)
	(path Orlando St-Augustine 2)
	(path Orlando Orlando 0)
)

(deftemplate package
	(slot number)
	(slot pickup)
	(slot dropoff)
	(slot size)
	(slot status (default unordered))
	(slot arrival-time)
	(slot expected-time)
	(slot pickup-time (default 0))
	(slot deliver-time (default 0))
	(slot lateness (default 0))
	(slot wait-time (default 0))
	(slot record-made (default 0))
	(slot record-printed (default 0))
)

(deftemplate truck
	(slot number)
	(slot location (default Orlando))
	(slot capacity)
	(slot package-held)
	(slot destination)
	(slot action)
	(slot clock)
	(slot time-to-dest)
	(slot wait-time)
	(slot time-busy)
	(slot busy-percent)
	(multislot packages-transported)
	(slot totalSizes)
	(slot non-deliver-time)
	(slot deliver-time)
	(slot busy-deliver-percent)
	(slot record-made)
)


(deffacts truck-init
	(total trucks 6)
	(idle-trucks 6)
	(truck (number 1)(capacity 5)(package-held none)
		(destination none)(action idle)(clock 0)(time-to-dest 0)
		(wait-time 0)(time-busy 0)(busy-percent 0)(totalSizes 0)
		(non-deliver-time 0)(deliver-time 0)(busy-deliver-percent 0)
		(record-made false))
	(truck (number 2)(capacity 5)(package-held none)
		(destination none)(action idle)(clock 0)(time-to-dest 0)
		(wait-time 0)(time-busy 0)(busy-percent 0)(totalSizes 0)
		(non-deliver-time 0)(deliver-time 0)(busy-deliver-percent 0)
		(record-made false))
	(truck (number 3)(capacity 10)(package-held none)
		(destination none)(action idle)(clock 0)(time-to-dest 0)
		(wait-time 0)(time-busy 0)(busy-percent 0)(totalSizes 0)
		(non-deliver-time 0)(deliver-time 0)(busy-deliver-percent 0)
		(record-made false))
	(truck (number 4)(capacity 10)(package-held none)
		(destination none)(action idle)(clock 0)(time-to-dest 0)
		(wait-time 0)(time-busy 0)(busy-percent 0)(totalSizes 0)
		(non-deliver-time 0)(deliver-time 0)(busy-deliver-percent 0)
		(record-made false)(location Gainesville))
	(truck (number 5)(capacity 10)(package-held none)
		(destination none)(action idle)(clock 0)(time-to-dest 0)
		(wait-time 0)(time-busy 0)(busy-percent 0)(totalSizes 0)
		(non-deliver-time 0)(deliver-time 0)(busy-deliver-percent 0)
		(record-made false)(location Gainesville))
	(truck (number 6)(capacity 15)(package-held none)
		(destination none)(action idle)(clock 0)(time-to-dest 0)
		(wait-time 0)(time-busy 0)(busy-percent 0)(totalSizes 0)
		(non-deliver-time 0)(deliver-time 0)(busy-deliver-percent 0)
		(record-made false))
	(truck (number 7)(capacity 15)(package-held none)
		(destination none)(action idle)(clock 0)(time-to-dest 0)
		(wait-time 0)(time-busy 0)(busy-percent 0)(totalSizes 0)
		(non-deliver-time 0)(deliver-time 0)(busy-deliver-percent 0)
		(record-made false)(location Miami))
	(truck (number 8)(capacity 15)(package-held none)
		(destination none)(action idle)(clock 0)(time-to-dest 0)
		(wait-time 0)(time-busy 0)(busy-percent 0)(totalSizes 0)
		(non-deliver-time 0)(deliver-time 0)(busy-deliver-percent 0)
		(record-made false)(location Miami))
	(truck (number 9)(capacity 20)(package-held none)
		(destination none)(action idle)(clock 0)(time-to-dest 0)
		(wait-time 0)(time-busy 0)(busy-percent 0)(totalSizes 0)
		(non-deliver-time 0)(deliver-time 0)(busy-deliver-percent 0)
		(record-made false)(location Miami))
	(truck (number 10)(capacity 20)(package-held none)
		(destination none)(action idle)(clock 0)(time-to-dest 0)
		(wait-time 0)(time-busy 0)(busy-percent 0)(totalSizes 0)
		(non-deliver-time 0)(deliver-time 0)(busy-deliver-percent 0)
		(record-made false)(location Miami))
)

(deffacts packages-init
	(wait-sum 0)
 (package (number 1)(pickup Orlando)(dropoff Jacksonville)(size 4)
	(arrival-time 1)(expected-time 10)) 
 (package (number 2)(pickup Gainesville)(dropoff Jacksonville)(size 9)
	(arrival-time 1)(expected-time 10)) 
 (package (number 3)(pickup St-Augustine)(dropoff Ft-Myers)(size 9)
	(arrival-time 3)(expected-time 15)) 
 (package (number 4)(pickup Jacksonville)(dropoff Key-West)(size 4)
	(arrival-time 3)(expected-time 20)) 
 (package (number 5)(pickup West-Palm)(dropoff St-Augustine)(size 13)
	(arrival-time 4)(expected-time 10)) 
 (package (number 6)(pickup Key-West)(dropoff St-Augustine)(size 4)
	(arrival-time 4)(expected-time 15)) 
 (package (number 7)(pickup Gainesville)(dropoff Tallahassee)(size 9)
	(arrival-time 5)(expected-time 12)) 
 (package (number 8)(pickup Miami)(dropoff Gainesville)(size 5)
	(arrival-time 7)(expected-time 30)) 
 (package (number 9)(pickup Miami)(dropoff Tallahassee)(size 5)
	(arrival-time 8)(expected-time 25)) 
 (package (number 10)(pickup Jacksonville)(dropoff Orlando)(size 10)
	(arrival-time 8)(expected-time 15)) 
 (package (number 11)(pickup Jacksonville)(dropoff Miami)(size 5)
	(arrival-time 8)(expected-time 15)) 
 (package (number 12)(pickup Ft-Myers)(dropoff Key-West)(size 4)
	(arrival-time 9)(expected-time 20)) 
 (package (number 13)(pickup Orlando)(dropoff Key-West)(size 14)
	(arrival-time 9)(expected-time 20)) 
 (package (number 14)(pickup West-Palm)(dropoff Miami)(size 2)
	(arrival-time 9)(expected-time 14)) 
 (package (number 15)(pickup Miami)(dropoff Ocala)(size 4)
	(arrival-time 10)(expected-time 20)) 
 (package (number 16)(pickup Gainesville)(dropoff Orlando)(size 7)
	(arrival-time 11)(expected-time 15)) 
 (package (number 17)(pickup Tampa)(dropoff Tallahassee)(size 12)
	(arrival-time 12)(expected-time 20)) 
 (package (number 18)(pickup St-Augustine)(dropoff Ft-Myers)(size 8)
	(arrival-time 13)(expected-time 30)) 
 (package (number 19)(pickup Gainesville)(dropoff Tallahassee)(size 6)
	(arrival-time 13)(expected-time 21)) 
 (package (number 20)(pickup West-Palm)(dropoff St-Augustine)(size 15)
	(arrival-time 14)(expected-time 20)) 
 (package (number 21)(pickup Key-West)(dropoff St-Augustine)(size 14)
	(arrival-time 14)(expected-time 25)) 
 (package (number 22)(pickup Jacksonville)(dropoff Key-West)(size 10)
	(arrival-time 15)(expected-time 33)) 
 (package (number 23)(pickup Jacksonville)(dropoff Tallahassee)(size 7)
	(arrival-time 20)(expected-time 25))	
 (package (number 24)(pickup Tallahassee)(dropoff Gainesville)(size 10)
	(arrival-time 22)(expected-time 32)) 
 (package (number 25)(pickup St-Augustine)(dropoff Ft-Myers)(size 15)
	(arrival-time 23)(expected-time 34)) 
 (package (number 26)(pickup Jacksonville)(dropoff Key-West)(size 12)
	(arrival-time 25)(expected-time 40)) 
 (package (number 27)(pickup Ocala)(dropoff Orlando)(size 7)
	(arrival-time 27)(expected-time 35)) 
 (package (number 28)(pickup Miami)(dropoff Orlando)(size 5)
	(arrival-time 28)(expected-time 38)) 
 (package (number 29)(pickup West-Palm)(dropoff Ft-Myers)(size 14)
	(arrival-time 30)(expected-time 43)) 
 (package (number 30)(pickup Orlando)(dropoff Lake-City)(size 6)
	(arrival-time 35)(expected-time 40)) 
 (package (number 31)(pickup Miami)(dropoff Gainesville)(size 5)
	(arrival-time 37)(expected-time 48)) 
 (package (number 32)(pickup Tampa)(dropoff Tallahassee)(size 12)
	(arrival-time 38)(expected-time 50)) 
 (package (number 33)(pickup Miami)(dropoff Key-West)(size 3)
	(arrival-time 40)(expected-time 45)) 
 (package (number 34)(pickup St-Augustine)(dropoff Ft-Myers)(size 8)
	(arrival-time 43)(expected-time 60)) 
 (package (number 35)(pickup Miami)(dropoff Ocala)(size 6)
	(arrival-time 45)(expected-time 55)) 
 (package (number 36)(pickup Gainesville)(dropoff Orlando)(size 7)
	(arrival-time 47)(expected-time 54)) 
 (package (number 37)(pickup St-Augustine)(dropoff Tallahassee)(size 8)
	(arrival-time 50)(expected-time 65)) 
 (package (number 38)(pickup Miami)(dropoff Tallahassee)(size 7)
	(arrival-time 52)(expected-time 70)) 
 (package (number 39)(pickup Tallahassee)(dropoff Lake-City)(size 8)
	(arrival-time 55)(expected-time 60)) 
 (package (number 40)(pickup Lake-City)(dropoff Tallahassee)(size 7)
	(arrival-time 60)(expected-time 67)) 
 (package (number 41)(pickup Tallahassee)(dropoff Key-West)(size 12)
	(arrival-time 62)(expected-time 82))	
 (package (number 42)(pickup St-Augustine)(dropoff Key-West)(size 5)
	(arrival-time 65)(expected-time 85)) 
 (package (number 43)(pickup Tampa)(dropoff Jacksonville)(size 9)
	(arrival-time 67)(expected-time 78)) 
 (package (number 44)(pickup Ft-Myers)(dropoff Key-West)(size 6)
	(arrival-time 70)(expected-time 80)) 
 (package (number 45)(pickup Miami)(dropoff Orlando)(size 7)
	(arrival-time 75)(expected-time 85)) 
 (package (number 46)(pickup Key-West)(dropoff St-Augustine)(size 15)
	(arrival-time 77)(expected-time 79)) 
 (package (number 47)(pickup Tallahassee)(dropoff Lake-City)(size 9)
	(arrival-time 80)(expected-time 85))
 (package (number 48)(pickup West-Palm)(dropoff Ft-Myers)(size 12)
	(arrival-time 80)(expected-time 95)) 
 (package (number 49)(pickup Tampa)(dropoff Tallahassee)(size 10)
	(arrival-time 81)(expected-time 84)) 
 (package (number 50)(pickup Orlando)(dropoff Key-West)(size 12)
	(arrival-time 82)(expected-time 85)) 
)