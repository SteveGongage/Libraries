<!--- =============================================================================================

Template: 	DataUtilities
Purpose:	A UDF library for various Data Conversion and Manipulation functions
Created:	7/17/2008 by Steven Gongage

	
=============================================================================================  --->


<cfcomponent extends="cf.Gongage.Utilities.UtilityBase">


	


	<cfscript>
		
		/* ============================================================== */
		public function newTimeSpan(
			required 	string 	spanUnitName	= 'day',
						date 	startDate 		= now(),
						any		endDate 		= ''
		) {
			var newSpan = new timeSpan(arguments.spanUnitName, arguments.startDate, arguments.endDate);
			return newSpan;
		}

		
		/* ============================================================== */
		public date function startOfDay(date dateIn = now()) {
			return createDate(year(dateIn), month(dateIn), day(dateIn));
		}
		/* ============================================================== */
		public date function firstDateOfWeek(date dateIn = now()) {
			return dateadd('d', -dayOfWeek(arguments.dateIn)+1, arguments.dateIn);
		}
		/* ============================================================== */
		public date function lastDateOfWeek(date dateIn = now()) {
			return dateadd('d', 6, firstDateOfWeek(arguments.dateIn));
		}
		/* ============================================================== */
		public date function firstDateOfMonth(date dateIn = now()) {
			return createDate(year(arguments.dateIn), month(arguments.dateIn), 1);
		}
		/* ============================================================== */
		public date function lastDateOfMonth(date dateIn = now()) {
			return createDate(year(arguments.dateIn), month(arguments.dateIn), daysInMonth(arguments.dateIn));	
		}
		/* ============================================================== */
		public date function firstDateOfYear(date dateIn = now()) {
			return createDate(year(arguments.dateIn), 1, 1);
		}
		/* ============================================================== */
		public date function firstDateOfFiscalYear(date dateIn = now()) {
			if (month(dateIn) GE 10) {
				return createDate(year(arguments.dateIn), 10, 1);
			} else {
				return createDate(year(arguments.dateIn) - 1, 10, 1);
			}
		}



	</cfscript>

</cfcomponent>