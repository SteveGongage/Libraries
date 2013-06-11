
<cfscript>
component initmethod="init"  {
	
	
	init();
	
	
	/* ============================================================== */
	public function init(
		required 	string 	spanUnitName	= 'day',
					date 	startDate 		= now(),
					any		endDate 		= ''
	) {
		this.utilities = structnew();
		this.utilities.time = new DateUtilities();

		/* request.adminAPI = createobject('component', 'cfide.adminapi.security'); */
		setReportDates(arguments.spanUnitName, arguments.startDate, arguments.endDate); 
		return this;
	}
	
	
	
	
	/* ============================================================== */
	public void function setReportDates(
		required 	string 	spanUnitName,
					date 	startDate 	= now(),
					any		endDate 	= ''
	){
		var cleanStartDate = createDate(year(arguments.startDate), month(arguments.startDate), day(arguments.startDate));
		var cleanEndDate = '';
		if (isDate(arguments.endDate)) {
			cleanEndDate = createDate(year(arguments.endDate), month(arguments.endDate), day(arguments.endDate));
		}

		this.settings.endDate = cleanEndDate;
		
		switch (arguments.spanUnitName) {
			case 'custom':
				this.settings.startDate				= cleanStartDate;
				this.settings.spanUnit 				= 'd';	
				this.settings.endDate				= dateAdd('s', -1, dateAdd('d', 1, cleanEndDate));
				this.settings.spanUnitName 			= 'Day';		
				this.settings.intervalUnit			= "d";
				this.settings.intervalName			= "Day";
				this.settings.spanDateFormat		= 'mmm d';		
				this.settings.intervalDateFormat 	= "mmm d";
				break;
			case 'day':
				this.settings.startDate				= cleanStartDate;
				this.settings.spanUnit 				= 'd';	
				this.settings.spanUnitName 			= 'Day';		
				this.settings.intervalUnit			= "d";
				this.settings.intervalName			= "Day";
				this.settings.spanDateFormat		= 'mmm d';		
				this.settings.intervalDateFormat 	= "mmm d";
				break;
			case 'week':	
				this.settings.startDate				= this.utilities.time.firstDateOfWeek(cleanStartDate);
				this.settings.spanUnit 				= 'ww';	
				this.settings.spanUnitName 			= 'Week';	
				this.settings.intervalUnit 			= "d";
				this.settings.intervalName			= "Day";
				this.settings.spanDateFormat		= 'mmm d';		
				this.settings.intervalDateFormat 	= "ddd d";
				break;
			case 'month':	
				this.settings.startDate				= this.utilities.time.firstDateOfMonth(cleanStartDate);
				this.settings.spanUnit 				= 'm';	
				this.settings.spanUnitName 			= 'Month';	
				this.settings.intervalUnit			= "ww";
				this.settings.intervalName			= "Week";
				this.settings.spanDateFormat		= 'mmm ''yy';		
				this.settings.intervalDateFormat 	= "mmm d";
				break;
			case 'year':	
				this.settings.startDate				= this.utilities.time.firstDateOfYear(cleanStartDate);
				this.settings.spanUnit 				= 'yyyy';	
				this.settings.spanUnitName 			= 'Year';	
				this.settings.intervalUnit			= "m";
				this.settings.intervalName			= "Month";
				this.settings.spanDateFormat		= 'yyyy';		
				this.settings.intervalDateFormat 	= "mmm";
				break;
			case 'fiscal':	
				this.settings.startDate				= this.utilities.time.firstDateOfFiscalYear(cleanStartDate);
				this.settings.spanUnit 				= 'yyyy';	
				this.settings.spanUnitName 			= 'Fiscal Year';	
				this.settings.intervalUnit			= "m";
				this.settings.intervalName			= "Month";
				this.settings.spanDateFormat		= 'yyyy';		
				this.settings.intervalDateFormat 	= "mmm";
				break;
			default: 
				this.settings.startDate				= cleanStartDate;
				this.settings.spanUnit 				= 'd';	
				this.settings.spanUnitName 			= 'Day';		
				this.settings.intervalUnit			= "d";
				this.settings.intervalName			= "Day";
				this.settings.spanDateFormat		= 'mmm d';		
				this.settings.intervalDateFormat 	= "mmm d";
				break;
		}
		
		if (NOT isDate(this.settings.endDate)) {
			this.settings.endDate	= dateAdd(this.settings.spanUnit, 1, this.settings.startDate);
			this.settings.endDate 	= dateAdd('s', -1, this.settings.endDate);
		}


	}

	
	/* ============================================================== */
	public struct function getTimeSpan(numeric offset = 0) { return calculateTimespan(offset); }

	
		
	
	/* ============================================================== */
	public array function getIntervalsFromTimeSpan(	struct timeSpan	) {
		// Create daily intervals between start and end dates 
		var intervals = arraynew(1);
		var currDate = timespan.dateStart;
		var i = 0;
		while (currDate < timespan.dateEnd AND i < 100) {
			i++;
			newInterval = {};
			newInterval.dateStart 	= currDate;
			currDate = dateAdd(timespan.intervalUnit, 1, currDate);
			newInterval.dateEnd 	= dateAdd('s', -1, currDate);

			arrayAppend(intervals, newInterval);
		}
		
		return intervals;
	}

	/* ============================================================== */
	/* ============================================================== */
	private struct function calculateTimespan(
		numeric offset			= 0
	) {
		var newSpan = {dateStart = this.settings.startDate, dateEnd = this.settings.endDate};
		newSpan.spanUnit		= this.settings.spanUnit;
		newSpan.spanUnitName	= this.settings.spanUnitName;
		newSpan.offset			= arguments.offset;
		//newSpan.intervals		= [];
		newSpan.intervalUnit	= this.settings.intervalUnit;
		newSpan.intervalName	= this.settings.intervalName;
		newSpan.spanDateFormat 		= this.settings.spanDateFormat;
		newSpan.intervalDateFormat 	= this.settings.intervalDateFormat;
		
		
		// Offset
		if (newSpan.offset IS NOT 0) {
			newSpan.dateStart 	= dateAdd(newSpan.spanUnit, newSpan.offset, newSpan.dateStart);
			//newSpan.dateEnd		= dateAdd(newSpan.spanUnit, newSpan.offset, newSpan.dateEnd);
			newSpan.dateEnd		= dateAdd('s', -1, dateAdd(newSpan.spanUnit, 1, newSpan.dateStart));
		}

		// remove 1 second from the end date, to bring it back to the correct date and make the dates fully inclusive 

		
		return newSpan;
	}
	

	
}

</cfscript>

