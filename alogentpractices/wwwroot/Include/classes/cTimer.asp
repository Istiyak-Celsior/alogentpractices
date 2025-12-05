<%

' The encapsulates a basic timer: start, stop and delta-t. It also
' can compare two timers and based on their delta-t set one of them
' to the larger or smaller change in time.
'
Class cTimer
	Public description
	Public startTime
	Public endTime
	
	
	' Constructor
	'
	Private Sub Class_Initialize()
		startTime = 0
		endTime = 0
		description = ""
	End Sub
	
	' Return the delta-T of the given timer
	'
	Public Property Get Delta()
		Delta = (endTime - startTime) * 100000
	End Property
	
	' Time stamp the start timer and clear the end time
	'
	Public Sub StartTimer()
		startTime = Now()
		endTime = 0
	End Sub
	
	' Time stamp the stop time for the timer
	'
	Public Sub StopTimer()
		endTime = Now()
	End Sub
	
	' Sets the Larger of the two timers based
	' on their delta values
	'
	Public Sub SetLarger(t)
		if t.Delta() > Me.Delta() then
			me.startTime = t.startTime
			me.endTime = t.endTime
			me.description = t.description
		end if
	End Sub
	
	' Sets the Smaller of the two timers based
	' on their delta values
	'
	Public Sub SetSmaller(t)
		if t.Delta() < Me.Delta() then
			me.startTime = t.startTime
			me.endTime = t.endTime
			me.description = t.description
		end if
	End Sub
End Class

%>