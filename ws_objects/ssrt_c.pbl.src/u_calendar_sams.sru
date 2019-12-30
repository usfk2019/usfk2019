$PBExportHeader$u_calendar_sams.sru
$PBExportComments$Drop-down calendar
forward
global type u_calendar_sams from userobject
end type
type pb_monprev from picturebutton within u_calendar_sams
end type
type pb_monnext from picturebutton within u_calendar_sams
end type
type pb_yrprev from picturebutton within u_calendar_sams
end type
type pb_yrnext from picturebutton within u_calendar_sams
end type
type dw_cal from datawindow within u_calendar_sams
end type
end forward

global type u_calendar_sams from userobject
integer width = 891
integer height = 704
long backcolor = 12632256
long tabtextcolor = 33554432
event ue_close pbm_custom01
event ue_popup ( )
event ue_clicked ( )
pb_monprev pb_monprev
pb_monnext pb_monnext
pb_yrprev pb_yrprev
pb_yrnext pb_yrnext
dw_cal dw_cal
end type
global u_calendar_sams u_calendar_sams

type variables


Protected:
   Integer    ii_old_column, ii_Day, ii_Month, ii_Year
   String     ls_DateFormat
   Datetime       id_date_selected
end variables

forward prototypes
public function integer uf_daysinmonth (integer vi_month, integer vi_year)
public subroutine uf_drawmonth (integer vi_year, integer vi_month)
public subroutine uf_enterdaynumbers (integer ai_start_day_num, integer ai_days_in_month)
public function integer uf_getmonthnumber (string vs_month)
public function string uf_getmonthstring (integer vs_month)
public subroutine uf_initcal (date vd_start_date)
public subroutine uf_setdate ()
public function string uf_datestring ()
end prototypes

public function integer uf_daysinmonth (integer vi_month, integer vi_year);Integer	ln_days_in_month
Boolean	lb_leap_year

/************************************************************************/
/* Most cases are straight forward in that there are a fixed number of 	*/
/* days in 11 of the 12 vi_months.  February is, of course, the problem.	*/
/* In a leap year February has 29 days, otherwise 28.							*/
/************************************************************************/

CHOOSE CASE vi_month
	CASE 1, 3, 5, 7, 8, 10, 12
		ln_days_in_month = 31
	CASE 4, 6, 9, 11
		ln_days_in_month = 30
	CASE 2
		/***********************/
		/* Check for leap year */
		/***********************/
		If IsDate(string(vi_year) + "/2/29") Then
			ln_days_in_month = 29
		Else
   		ln_days_in_month = 28
		End If
END CHOOSE

Return ln_days_in_month
end function

public subroutine uf_drawmonth (integer vi_year, integer vi_month);Integer	li_FirstDayNum, li_cell, li_daysinmonth
Date 		ld_firstday
String	ls_modify, ls_return

dw_cal.SetRedraw(FALSE)

ii_month = vi_month
ii_year  = vi_year

/*********************************************************************/
/* Check if the instance day is valid for month/year.						*/
/* Back the day down one if invalid for month ie 31 will become 30	*/
/*********************************************************************/
Do While Date(ii_year,ii_month,ii_day) = Date(00,1,1)
	ii_day --
Loop

/* Work out how many days in the month */
li_daysinmonth = uf_DaysInMonth(ii_month,ii_year)

/* Find the date of the first day in the month */
ld_firstday = Date(ii_year,ii_month,1)

/* Find what day of the week this is */
li_FirstDayNum = DayNumber(ld_firstday)

/* Set the first cell */
li_cell = li_FirstDayNum + ii_day - 1

/* If there was an old column turn off the highlight */
If ii_old_column <> 0 then
	ls_modify = "#" + string(ii_old_Column) + ".border=0"
	ls_return = dw_cal.Modify(ls_modify)
	If ls_return <> "" then MessageBox("Modify",ls_return)
End If

/* Set the Title */
dw_cal.Modify("st_year.text=~"" + string(ii_year) + "~"")
dw_cal.Modify("st_month.text=~"" + uf_GetMonthString(ii_month) + "~"")

uf_EnterDayNumbers(li_FirstDayNum,li_daysinmonth)

dw_cal.SetItem(1, li_cell, String(ii_day))

/* Highlight the current date */
ls_modify = "#" + string(li_cell) + ".border=5"
ls_return = dw_cal.Modify(ls_modify)
If ls_return <> "" then MessageBox("Modify",ls_return)

/* Set the old column for next time */
ii_old_column = li_cell

/* Reset the pointer and Redraw */
SetPointer(Arrow!)
dw_cal.SetRedraw(TRUE)

end subroutine

public subroutine uf_enterdaynumbers (integer ai_start_day_num, integer ai_days_in_month);Integer	li_count, li_daycount
string	ls_modify, ls_return

/* Blank the columns before the first day of the month */
For li_count = 1 to ai_start_day_num
	dw_cal.SetItem(1,li_count,"")
Next

/* Set the columns for the days to the String of their Day number */
For li_count = 1 to ai_days_in_month
	/* Use li_daycount to find which column needs to be set */
	li_daycount = ai_start_day_num + li_count - 1
	dw_cal.SetItem(1,li_daycount,String(li_count))
Next

/* Move to next column */
li_daycount = li_daycount + 1

/* Blank remainder of columns */
For li_count = li_daycount to 42
	dw_cal.SetItem(1,li_count,"")
Next


/* If there was an old column turn off the highlight */
If ii_old_column <> 0 then
	ls_modify = "#" + string(ii_old_Column) + ".border=0"
	ls_return = dw_cal.Modify(ls_modify)
	If ls_return <> "" then MessageBox("Modify",ls_return)
End If


ii_old_column = 0


end subroutine

public function integer uf_getmonthnumber (string vs_month);Integer li_month_number

CHOOSE CASE vs_month
	CASE "Jan"
		li_month_number = 1
	CASE "Feb"
		li_month_number = 2
	CASE "Mar"
		li_month_number = 3
	CASE "Apr"
		li_month_number = 4
	CASE "May"
		li_month_number = 5
	CASE "Jun"
		li_month_number = 6
	CASE "Jul"
		li_month_number = 7
	CASE "Aug"
		li_month_number = 8
	CASE "Sep"
		li_month_number = 9
	CASE "Oct"
		li_month_number = 10
	CASE "Nov"
		li_month_number = 11
	CASE "Dec"
		li_month_number = 12
END CHOOSE

Return li_month_number
end function

public function string uf_getmonthstring (integer vs_month);String ls_month

CHOOSE CASE vs_month
	CASE 1
		ls_month = "January"
	CASE 2
		ls_month = "February"
	CASE 3
		ls_month = "March"
	CASE 4
		ls_month = "April"
	CASE 5
		ls_month = "May"
	CASE 6
		ls_month = "June"
	CASE 7
		ls_month = "July"
	CASE 8
		ls_month = "August"
	CASE 9
		ls_month = "September"
	CASE 10
		ls_month = "October"
	CASE 11
		ls_month = "November"
	CASE 12
		ls_month = "December"
END CHOOSE

Return ls_month
end function

public subroutine uf_initcal (date vd_start_date);Integer	li_FirstDayNum, li_Cell, li_DaysInMonth
String 	ls_Year, ls_Modify, ls_Return
Date 		ld_FirstDay

/* Insert a row into the script datawindow */
dw_cal.Reset()
dw_cal.InsertRow(0)

/*********************************************************************/
/* Set the variables for Day, Month and Year from the date passed to */
/* the function																		*/
/*********************************************************************/
ii_Month = Month(vd_start_date)
ii_Year  = Year(vd_start_date)
ii_Day   = Day(vd_start_date)

/* Find how many days in the relevant month */
li_daysinmonth = uf_DaysInMonth(ii_month,ii_year)

/* Find the date of the first day of this month */
ld_FirstDay = Date(ii_Year,ii_month,1)

/* What day of the week is the first day of the month */
li_FirstDayNum = DayNumber(ld_FirstDay)

/*********************************************************************/
/* Set the starting "cell" in the datawindow. i.e the column in which*/
/* the first day of the month will be displayed								*/
/*********************************************************************/
li_Cell = li_FirstDayNum + ii_Day - 1

/* Set the Title of the calendar with the Month and Year */
dw_cal.Modify("st_year.text=~"" + string(ii_Year) + "~"")
dw_cal.Modify("st_month.text=~"" + uf_GetMonthString(ii_Month) + "~"")

/* Enter the numbers of the days */
uf_EnterDayNumbers(li_FirstDayNum, li_DaysInMonth)

dw_cal.SetItem(1,li_cell,String(Day(vd_start_date)))

/* Display the first day in bold (or 3D) */
ls_modify = "#" + string(li_cell) + ".border=5"
ls_return = dw_cal.Modify(ls_Modify)
If ls_return <> "" then MessageBox("Modify",ls_return)

/*********************************************************************/
/* Set the instance variable i_old_column to hold the current cell,	*/
/* so when we change it, we know the old setting							*/
/*********************************************************************/
ii_old_column = li_Cell

end subroutine

public subroutine uf_setdate ();dw_cal.Reset()

If ii_day = 0 Then ii_day = 1
uf_InitCal(date(ii_year, ii_month, ii_day))

dw_cal.SetFocus()
end subroutine

public function string uf_datestring ();Return String(ii_year) + "/" + String(ii_month) + "/"+ String(ii_day)
end function

on u_calendar_sams.create
this.pb_monprev=create pb_monprev
this.pb_monnext=create pb_monnext
this.pb_yrprev=create pb_yrprev
this.pb_yrnext=create pb_yrnext
this.dw_cal=create dw_cal
this.Control[]={this.pb_monprev,&
this.pb_monnext,&
this.pb_yrprev,&
this.pb_yrnext,&
this.dw_cal}
end on

on u_calendar_sams.destroy
destroy(this.pb_monprev)
destroy(this.pb_monnext)
destroy(this.pb_yrprev)
destroy(this.pb_yrnext)
destroy(this.dw_cal)
end on

event constructor;id_date_selected = fdt_get_dbserver_now()
end event

type pb_monprev from picturebutton within u_calendar_sams
integer x = 14
integer y = 92
integer width = 110
integer height = 84
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string picturename = "Prior.bmp"
end type

event clicked;INTEGER li_year, li_month, li_day
date   	ldt_today, ldt_click_dt

ldt_today 	=	date(fdt_get_dbserver_now())
li_year 		=  ii_year
li_month 	=  ii_month
li_day 		=  ii_day


/* Decrement the month, if 0, set to 12 (December) */
ii_month = ii_month - 1
If ii_month = 0 then
	ii_month = 12
	ii_year = ii_year - 1
End If

/* check if selected day is no longer valid for new month */
If not(isdate(uf_datestring())) Then ii_day = 1
ldt_click_dt = date(ii_year, ii_month, ii_day)
IF ldt_click_dt < ldt_today THEN
	ii_year	= li_year
	ii_month	= li_month
	ii_day	= li_day
	return
END IF


/* Darw the month */
uf_DrawMonth ( ii_year, ii_month )

id_date_selected = dateTIME(DATE(ii_year,ii_month,ii_Day), TIME(fdt_get_dbserver_now()))


end event

type pb_monnext from picturebutton within u_calendar_sams
integer x = 750
integer y = 92
integer width = 110
integer height = 84
integer taborder = 30
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string picturename = "Next.bmp"
end type

event clicked;/* Increment the month number, but if its 13, set back to 1 (January) */
ii_month = ii_month + 1
If ii_month = 13 then
	ii_month = 1
	ii_year = ii_year + 1
End If

/* check if selected day is no longer valid for new month */
If not(isdate(uf_datestring())) Then ii_day = 1
	
/* Draw the month */
uf_DrawMonth ( ii_year, ii_month )

id_date_selected = dateTIME(DATE(ii_year,ii_month,ii_Day), TIME(fdt_get_dbserver_now()))

end event

type pb_yrprev from picturebutton within u_calendar_sams
integer x = 14
integer y = 8
integer width = 110
integer height = 84
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string picturename = "Prior.bmp"
end type

event clicked;INTEGER li_year, li_month, li_day
date   	ldt_today, ldt_click_dt

ldt_today 	=	date(fdt_get_dbserver_now())
li_year 		=  ii_year
li_month 	=  ii_month
li_day 		=  ii_day




ii_year --

/* check if selected day is no longer valid */
If not(isdate(uf_datestring())) Then ii_day = 1
ldt_click_dt = date(ii_year, ii_month, ii_day)
IF ldt_click_dt < ldt_today THEN
	ii_year	= li_year
	ii_month	= li_month
	ii_day	= li_day
	return
END IF
	
/* Draw the month */
uf_DrawMonth ( ii_year, ii_month )

id_date_selected = dateTIME(DATE(ii_year,ii_month,ii_Day), TIME(fdt_get_dbserver_now()))

end event

type pb_yrnext from picturebutton within u_calendar_sams
integer x = 750
integer y = 8
integer width = 110
integer height = 84
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string picturename = "Next.bmp"
end type

event clicked;ii_year ++

/* check if selected day is no longer valid */
If not(isdate(uf_datestring())) Then ii_day = 1
	
/* Draw the month */
uf_DrawMonth ( ii_year, ii_month )

id_date_selected = dateTIME(DATE(ii_year,ii_month,ii_Day), TIME(fdt_get_dbserver_now()))

end event

type dw_cal from datawindow within u_calendar_sams
event ue_dwnkey pbm_dwnkey
integer width = 882
integer height = 700
integer taborder = 10
string dataobject = "d_calendar_sams"
boolean border = false
end type

event clicked;Integer	li_clickedcolumn
String 	ls_day, ls_modify, ls_return

datetime   	ldt_today, ldt_click_dt

ldt_today =	fdt_get_dbserver_now()

//ii_year = INTEGER(st_year.text)
//ii_month = INTEGER(st_month.text)
//

if NOT dwo.Type = "column" then Return

//Find which column was clicked on and return if it is not valid
li_clickedcolumn = Integer(dwo.ID)
If li_clickedcolumn < 0 then Return

// Set Day to the text of the clicked column. Return if it is an
// empty column
ls_day = dw_cal.GetItemString(1, li_clickedcolumn)
If ls_day = "" then Return

// Convert to a number and place in Instance variable
ii_day = Integer(ls_day)

ldt_click_dt = datetime(date(ii_year, ii_month, ii_day), time(fdt_get_dbserver_now()))
IF ldt_click_dt < ldt_today THEN
	return
END IF


dw_cal.SetItem(1, li_clickedcolumn,ls_day)

// If the highlight was on a previous column (i_old_column = 0)
// set the border of the old column back to normal
If ii_old_column <> 0 then
	ls_modify = "#" + String(ii_old_Column) + ".border=0"
	ls_return = dw_cal.Modify(ls_modify)
	If ls_return <> "" then MessageBox("Modify",ls_return)
End If

// Highlight chosen day
ls_modify = "#" + String(li_clickedcolumn) + ".border=5"
ls_return = dw_cal.Modify(ls_modify)
If ls_return <> "" then MessageBox("Modify",ls_return)


// Set the old column for next time
ii_old_column = li_clickedcolumn


// Return the chosen date
id_date_selected = Datetime(date(ii_year,ii_month,ii_Day),time(fdt_get_dbserver_now()))
parent.PostEvent("ue_clicked")

//parent.PostEvent("ue_close")
end event

event constructor;this.SetTransObject(sqlca)

end event

event doubleclicked;Integer	li_clickedcolumn
String 	ls_day, ls_modify, ls_return

dateTIME   	ldt_today, ldt_click_dt

ldt_today =	fdt_get_dbserver_now()

//ii_year = INTEGER(st_year.text)
//ii_month = INTEGER(st_month.text)
//

if NOT dwo.Type = "column" then Return

//Find which column was clicked on and return if it is not valid
li_clickedcolumn = Integer(dwo.ID)
If li_clickedcolumn < 0 then Return

// Set Day to the text of the clicked column. Return if it is an
// empty column
ls_day = dw_cal.GetItemString(1, li_clickedcolumn)
If ls_day = "" then Return

// Convert to a number and place in Instance variable
ii_day = Integer(ls_day)

ldt_click_dt = dateTIME(DATE(ii_year,ii_month,ii_Day), TIME(fdt_get_dbserver_now()))

IF ldt_click_dt < ldt_today THEN
	return
END IF


//ii_year = Integer(dw_cal.Describe("st_year.text"))





dw_cal.SetItem(1,li_clickedcolumn,ls_day)

// If the highlight was on a previous column (i_old_column = 0)
// set the border of the old column back to normal
If ii_old_column <> 0 then
	ls_modify = "#" + String(ii_old_Column) + ".border=0"
	ls_return = dw_cal.Modify(ls_modify)
	If ls_return <> "" then MessageBox("Modify",ls_return)
End If

// Highlight chosen day
ls_modify = "#" + String(li_clickedcolumn) + ".border=5"
ls_return = dw_cal.Modify(ls_modify)
If ls_return <> "" then MessageBox("Modify",ls_return)


// Set the old column for next time
ii_old_column = li_clickedcolumn


// Return the chosen date
id_date_selected = dateTIME(DATE(ii_year,ii_month,ii_Day), TIME(fdt_get_dbserver_now()))


parent.PostEvent("ue_popup")
end event

