
<cfscript>
component extends="DateUtilities" initmethod="init"  {
	
	

	
	/* ============================================================== */
	public function init(
		required 	string 	spanUnitName	= 'day',
					date 	startDate 		= now(),
					any		endDate 		= ''
	) {
		this.dateStart 			= arguments.startDate;
		this.dateEnd			= arguments.endDate;

		this.span = {
			UnitName		= arguments.spanUnitName,
			Unit			= '',
			DateFormat 		= ''
		};	
		
		this.interval = {
			spanUnit 		= '',
			spanUnitName 	= '',
			dateFormat 		= ''
		};
		setReportDates(arguments.spanUnitName, arguments.startDate, arguments.endDate); 
		
		return this;
	}
	

	
	/* ============================================================== */
	public struct function getOffset(numeric offset = 0) { 
		var newDate.Start 	= this.dateStart;
		var newDate.End 	= this.dateEnd;
	
		if (arguments.offset IS NOT 0) {
			newDate.Start 	= dateAdd(this.span.Unit, arguments.offset, newDate.Start);
			newDate.End		= dateAdd('s', -1, dateAdd(this.span.Unit, 1, newDate.Start));
		}


		return new TimeSpan(this.span.UnitName, newDate.Start, newDate.End);
	}

	
		
	
	/* ============================================================== */
	public array function getIntervals(	struct timeSpan	) {
		// Create daily intervals between start and end dates 
		var intervals = arraynew(1);
		var currDate = this.dateStart;
		var i = 0;

		if (this.span.unit IS 'd') {
			/* there is no smaller interval currently than a day */
			intervals = [this];

		} else {
			var baseInterval = new TimeSpan(this.interval.spanUnit, this.dateStart);
			while (currDate < this.dateEnd AND i < 100) {
				newInterval = baseInterval.getOffset(i);
				currDate = newInterval.dateEnd;
				i++;

				/*
				newInterval = {};
				newInterval.dateStart 	= currDate;
				currDate = dateAdd(this.interval.spanUnit, 1, currDate);
				newInterval.dateEnd 	= dateAdd('s', -1, currDate);
				*/

				arrayAppend(intervals, newInterval);
			}
		
		}

			
		return intervals;
	}

	
	
	
	/* ============================================================== */
	/* ============================================================== */
	private void function setReportDates(
		required 	string 	spanUnitName,
					date 	startDate 	= now(),
					any		endDate 	= ''
	){
		var cleanStartDate = startOfDay(arguments.startDate);
		var cleanEndDate = '';
		if (isDate(arguments.endDate)) {
			cleanEndDate = startOfDay(dateAdd('s', -1, arguments.endDate));
		}


		
		switch (arguments.spanUnitName) {
			case 'custom':
				this.dateStart				= cleanStartDate;
				this.span.Unit 				= 'd';	
				this.dateEnd				= dateAdd('s', -1, dateAdd('d', 1, cleanEndDate));
				this.span.UnitName 			= 'Day';		
				this.interval.spanUnit		= "d";
				this.interval.spanUnitName	= "Day";
				this.span.DateFormat		= 'mmm d';		
				this.interval.dateFormat 	= "mmm d";
				break;
			case 'day':
				this.dateStart				= cleanStartDate;
				this.span.Unit 				= 'd';	
				this.span.UnitName 			= 'Day';		
				this.interval.spanUnit		= "d";
				this.interval.spanUnitName	= "Day";
				this.span.DateFormat		= 'mmm d';		
				this.interval.dateFormat 	= "mmm d";
				break;
			case 'week':	
				this.dateStart				= firstDateOfWeek(cleanStartDate);
				this.span.Unit 				= 'ww';	
				this.span.UnitName 			= 'Week';	
				this.interval.spanUnit 		= "d";
				this.interval.spanUnitName	= "Day";
				this.span.DateFormat		= 'mmm d';		
				this.interval.dateFormat 	= "ddd d";
				break;
			case 'month':	
				this.dateStart				= firstDateOfMonth(cleanStartDate);
				this.span.Unit				= 'm';	
				this.span.UnitName 			= 'Month';	
				this.interval.spanUnit		= "ww";
				this.interval.spanUnitName	= "Week";
				this.span.DateFormat		= 'mmm ''yy';		
				this.interval.dateFormat 	= "mmm d";
				break;
			case 'year':	
				this.dateStart				= firstDateOfYear(cleanStartDate);
				this.span.Unit				= 'yyyy';	
				this.span.UnitName 			= 'Year';	
				this.interval.spanUnit		= "m";
				this.interval.spanUnitName	= "Month";
				this.span.DateFormat		= 'yyyy';		
				this.interval.dateFormat 	= "mmm";
				break;
			case 'fiscal':	
				this.dateStart				= firstDateOfFiscalYear(cleanStartDate);
				this.span.Unit				= 'yyyy';	
				this.span.UnitName 			= 'Fiscal Year';	
				this.interval.spanUnit		= "m";
				this.interval.spanUnitName	= "Month";
				this.span.DateFormat		= 'yyyy';		
				this.interval.dateFormat 	= "mmm";
				break;
			default: 
				this.dateStart				= cleanStartDate;
				this.span.Unit				= 'd';	
				this.span.UnitName 			= 'Day';		
				this.interval.spanUnit		= "d";
				this.interval.spanUnitName	= "Day";
				this.span.DateFormat		= 'mmm d';		
				this.interval.dateFormat 	= "mmm d";
				break;
		}
		
		if (NOT isDate(this.dateEnd)) {
			this.dateEnd	= dateAdd(this.span.Unit, 1, this.dateStart);
			this.dateEnd 	= dateAdd('s', -1, this.dateEnd);
		}


	}

	/* ============================================================== */
	private function calculateTimespan(
		numeric offset			= 0
	) {
		
		
		// Offset
		this.dateStart 	= dateAdd(this.span.Unit, arguments.offset, this.dateStart);
		this.dateEnd	= dateAdd('s', -1, dateAdd(this.span.Unit, 1, this.dateStart));


	}
	

	
}

</cfscript>

