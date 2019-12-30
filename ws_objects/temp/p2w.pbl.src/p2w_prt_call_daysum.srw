$PBExportHeader$p2w_prt_call_daysum.srw
$PBExportComments$[kem] 사업자정산이용요금일자별합계조회
forward
global type p2w_prt_call_daysum from w_a_print
end type
type dw_tmp from u_d_base within p2w_prt_call_daysum
end type
end forward

global type p2w_prt_call_daysum from w_a_print
integer width = 3351
dw_tmp dw_tmp
end type
global p2w_prt_call_daysum p2w_prt_call_daysum

type variables
String is_svctype
end variables

forward prototypes
public function integer wf_inq_cdr (string as_fromdt, string as_todt)
end prototypes

public function integer wf_inq_cdr (string as_fromdt, string as_todt);//**   Argument : as_fromdt, as_todt  //일자

String  ls_type, ls_tname, ls_sql, ls_sql_1, ls_where, ls_where1
String  ls_yyyymmdd, ls_timefrom, ls_timeto, ls_fromdt, ls_todt
String  ls_svctype, ls_sacnum
Long    ll_rows, ll_time, ll_time1, ll_nopay


ls_fromdt   = String(dw_cond.Object.fromdt[1], 'yyyymmdd')
ls_todt     = String(dw_cond.Object.todt[1], 'yyyymmdd')
ls_timefrom = String(dw_cond.Object.time_from[1], 'HHMM')
ls_timeto   = String(dw_cond.Object.time_to[1], 'HHMM')
ll_nopay    = dw_cond.Object.nopay[1]
ls_svctype  = Trim(dw_cond.Object.svctype[1])
ls_sacnum   = Trim(dw_cond.Object.sacnum[1])

If ls_svctype = '0' Or ls_svctype = '2' Then
	ls_type = 'PRE_CDR'
Else
	ls_type = 'POST_CDR'
End If

If IsNull(ll_nopay) Then ll_nopay = 0

If ls_timefrom <> "" Then
	ls_where += " And "
	ls_where += " to_char(rtime, 'HH24MM') >= '" + ls_timefrom + "' "
End If
If ls_timeto <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(rtime, 'HH24MM') <= '" + ls_timeto + "' "
End If

If ls_sacnum <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " pbxno = '" + ls_sacnum + "' "
End If

If dw_cond.Object.n011[1] = 'Y' Then
	If ls_where1 <> "" Then ls_where1 += " Or "
	ls_where1 += " stelnum Like '011%' "
End If
If dw_cond.Object.n016[1] = 'Y' Then
	If ls_where1 <> "" Then ls_where1 += " Or "
	ls_where1 += " stelnum Like '016%' "
End If
If dw_cond.Object.n017[1] = 'Y' Then
	If ls_where1 <> "" Then ls_where1 += " Or "
	ls_where1 += " stelnum Like '017%' "
End If
If dw_cond.Object.n19[1] = 'Y' Then
	If ls_where1 <> "" Then ls_where1 += " Or "
	ls_where1 += " stelnum LIke '19%' "
End If
If dw_cond.Object.n010[1] = 'Y' Then
	If ls_where1 <> "" Then ls_where1 += " Or "
	ls_where1 += " stelnum Like '010%' "
End If
If dw_cond.Object.n018[1] = 'Y' Then
	If ls_where1 <> "" Then ls_where1 += " Or "
	ls_where1 += " stelnum LIke '018%' "
End If
If dw_cond.Object.n2[1] = 'Y' Then
	If ls_where1 <> "" Then ls_where1 += " Or "
	ls_where1 += " stelnum LIke '2%' "
End If
If dw_cond.Object.n3[1] = 'Y' Then
	If ls_where1 <> "" Then ls_where1 += " Or "
	ls_where1 += " stelnum Like '3%' "
End If
If dw_cond.Object.n4[1] = 'Y' Then
	If ls_where1 <> "" Then ls_where1 += " Or "
	ls_where1 += " stelnum Like '4%' "
End If
If dw_cond.Object.n5[1] = 'Y' Then
	If ls_where1 <> "" Then ls_where1 += " Or "
	ls_where1 += " stelnum Like '5%' "
End If
If dw_cond.Object.n6[1] = 'Y' Then
	If ls_where1 <> "" Then ls_where1 += " Or "
	ls_where1 += " stelnum Like '6%' "
End If
If dw_cond.Object.netc[1] = 'Y' Then
	If ls_where1 <> "" Then ls_where1 += " Or "
	ls_where1 += " ( stelnum not like '016%' "
	ls_where1 += "   And stelnum not like '011%' "
	ls_where1 += "   And stelnum not like '19%'  "
	ls_where1 += "   And stelnum not like '017%'  "
	ls_where1 += "   And stelnum not like '018%'  "
	ls_where1 += "   And stelnum not like '010%'  "
	ls_where1 += "   And stelnum not like '2%'    "
	ls_where1 += "   And stelnum not like '3%'    "
	ls_where1 += "   And stelnum not like '4%'    "
	ls_where1 += "   And stelnum not like '5%'    "
	ls_where1 += "   And stelnum not like '6%' )  "

End If

If ls_where1 <> "" Then
	ls_where += " And ( " + ls_where1 + ") "
End If

DECLARE cur_cdr_table DYNAMIC CURSOR FOR SQLSA;
DECLARE cur_cdr DYNAMIC CURSOR FOR SQLSA;

ls_sql = "SELECT tname " + &
			"FROM tab " + &
			"WHERE tabtype = 'TABLE' " + &
			" AND " + "tname >= '" + ls_type + as_fromdt + "' " + &
			" AND " + "tname <= '" + ls_type + as_todt + "' "  + &
			" AND LENGTH(TNAME) <= 16 " + &
			" ORDER BY tname ASC"
	
PREPARE SQLSA FROM :ls_sql;
OPEN DYNAMIC cur_cdr_table;

//DW 초기화
ll_rows = dw_list.RowCount()
If ll_rows > 0 Then dw_list.RowsDiscard(1, ll_rows, Primary!)
ll_rows = 0

Do While(True)
	FETCH cur_cdr_table
	INTO :ls_tname;

	If SQLCA.SQLCode < 0 Then
		clipboard(ls_sql)
		f_msg_sql_err(title, " cur_cdr_table")
		CLOSE cur_cdr_table;
		Return -1
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
	End If
   
	//검색된 테이블에서 자료를 읽기
	ls_sql_1 = " SELECT to_char(rtime, 'yyyymmdd') yyyymmdd,              " + &
              "        sum(round((etime-rtime) * 24 * 60 * 60)) time,    " + &
				  "        A.time time1                                      " + &
	           " FROM   " + ls_tname + &
				  "        , ( SELECT to_char(rtime, 'yyyymmdd') yyyymmdd    " + &
				  "                 , sum(round((etime-rtime) * 24 * 60 * 60) - to_number( '" + string(ll_nopay) + "' ) ) time " + &
				  "            FROM   " + ls_tname + &
				  "            WHERE  round((etime-rtime) * 24 * 60 * 60) - to_number( '" + string(ll_nopay) + "' ) > 0 " + &
				  "            AND    svctype = '" + ls_svctype + "'                    " + &
				  "            AND    to_char(rtime, 'yyyymmdd') >= '" + ls_fromdt + "' " + &
				  "            AND    to_char(rtime, 'yyyymmdd') <= '" + ls_todt + "'   " + &
				               + ls_where + &
	    		  "            GROUP BY to_char(rtime, 'yyyymmdd') ) A                  " + &
				  " WHERE  svctype = '" + ls_svctype + "'                               " + &
				  " AND    to_char(rtime, 'yyyymmdd') = a.yyyymmdd                      " + &
				  " AND    to_char(rtime, 'yyyymmdd') >= '" + ls_fromdt + "'            " + &
				  " AND    to_char(rtime, 'yyyymmdd') <= '" + ls_todt + "'              " + &
				  + ls_where + &
	    		  " GROUP BY to_char(rtime, 'yyyymmdd'), A.time "
					

	clipboard(ls_sql_1)		  
  	dw_tmp.SetSqlSelect(ls_sql_1)
	
	//조회
	ll_rows = dw_tmp.Retrieve()
	If ll_rows > 0 Then
		//복사한다.
		dw_tmp.RowsCopy(1,dw_tmp.RowCount(), &
									Primary!,dw_list ,1, Primary!)
	End If    
Loop
CLOSE cur_cdr_table;

If dw_list.RowCount() > 0 Then
	dw_list.SetSort("yyyymmdd A")
	dw_list.Sort()
End If

Return 1
end function

event ue_ok();call super::ue_ok;//조회
String ls_fromdt, ls_todt, ls_time_from, ls_time_to, ls_nopay, ls_sysdate, ls_next_todt
String ls_n011, ls_n016, ls_n017, ls_n019, ls_n010, ls_n0
String ls_n02, ls_n03, ls_n04, ls_n05, ls_n06, ls_netc, ls_num, ls_svctype, ls_sacnum
Long   ll_nopay

//필수입력사항 check
ls_fromdt    = String(dw_cond.Object.fromdt[1], "yyyymmdd")
ls_todt      = String(dw_cond.Object.todt[1], "yyyymmdd")
ls_time_from = String(dw_cond.Object.time_from[1], "hhmm")
ls_time_to   = String(dw_cond.object.time_to[1], "hhmm")
ll_nopay     = dw_cond.Object.nopay[1]
ls_svctype   = dw_cond.Object.svctype[1]
ls_sacnum    = dw_cond.Object.sacnum[1]

If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_todt) Then ls_todt = ""
If IsNull(ls_time_from) Then ls_time_from = ""				
If IsNull(ls_time_to) Then ls_time_to = ""
If IsNull(ls_svctype) Then ls_svctype = ""
If IsNull(ls_sacnum) Then ls_sacnum = ""


If ls_fromdt = "" Then
	f_msg_info(200, Title, "일자")
	dw_cond.SetFocus()
	dw_cond.setColumn("fromdt")
	Return 
End If

If ls_todt = "" Then
	f_msg_info(200, Title, "일자")
	dw_cond.SetFocus()
	dw_cond.setColumn("todt")
	Return 
End If

If ls_fromdt > ls_todt Then
	f_msg_usr_err(210, is_title, "일자")
	dw_cond.SetFocus()
	dw_cond.setColumn("fromdt")
	Return
End If

If ll_nopay < 0 Then
	f_msg_info(200, Title, "무료통화")
	dw_cond.SetFocus()
	dw_cond.setColumn("nopay")
	Return 
End If

If ls_svctype = "" Then
	f_msg_info(200, Title, "서비스타입")
	dw_cond.SetFocus()
	dw_cond.setColumn("svctype")
	Return 
End If

If Trim(dw_cond.Object.n011[1]) = "Y" Then
	If ls_num <> "" Then ls_num += ", "
	ls_num += "011"
End If
If Trim(dw_cond.Object.n016[1]) = "Y" Then
	If ls_num <> "" Then ls_num += ", "
	ls_num += "016"
End If
If Trim(dw_cond.Object.n017[1]) = "Y" Then
	If ls_num <> "" Then ls_num += ", "
	ls_num += "017"
End If
If Trim(dw_cond.Object.n19[1]) = "Y" Then
	If ls_num <> "" Then ls_num += ", "
	ls_num += "19"
End If
If Trim(dw_cond.Object.n010[1]) = "Y" Then
	If ls_num <> "" Then ls_num += ", "
	ls_num += "010"
End If
If Trim(dw_cond.Object.n018[1]) = "Y" Then
	If ls_num <> "" Then ls_num += ", "
	ls_num += "018"
End If
If Trim(dw_cond.Object.n2[1]) = "Y" Then
	If ls_num <> "" Then ls_num += ", "
	ls_num += "2"
End If
If Trim(dw_cond.Object.n3[1]) = "Y" Then
	If ls_num <> "" Then ls_num += ", "
	ls_num += "3"
End If
If Trim(dw_cond.Object.n4[1]) = "Y" Then
	If ls_num <> "" Then ls_num += ", "
	ls_num += "4"
End If
If Trim(dw_cond.Object.n5[1]) = "Y" Then
	If ls_num <> "" Then ls_num += ", "
	ls_num += "5"
End If
If Trim(dw_cond.Object.n6[1]) = "Y" Then
	If ls_num <> "" Then ls_num += ", "
	ls_num += "6"
End If
If Trim(dw_cond.Object.netc[1]) = "Y" Then
	If ls_num <> "" Then ls_num += ", "
	ls_num += "기타"
End If

//If ls_num = "" Then
//	f_msg_usr_err(210, is_title, "발신지")
//	dw_cond.SetFocus()
//	dw_cond.setColumn("n011")
//	Return
//End If

//todt의 다음날짜 구하기
ls_sysdate = String(fdt_get_dbserver_now(), 'YYYYMMDD')
If ls_todt = ls_sysdate Then
	ls_next_todt = ls_todt
Else
	ls_next_todt = String(fd_date_next(dw_cond.Object.todt[1], 1), "yyyymmdd")
End If

SetPointer(HourGlass!)
dw_list.setredraw(False)

If wf_inq_cdr(ls_fromdt, ls_next_todt) = -1 Then
	dw_list.setredraw(True)
	SetPointer(Arrow!)
	return 
End if

dw_list.Object.t_date.Text  = LeftA(ls_fromdt,4) + '-' + MidA(ls_fromdt,5,2) + '-' + RightA(ls_fromdt,2) + ' ~~ ' &
                            + LeftA(ls_todt,4) + '-' + MidA(ls_todt,5,2) + '-' + RightA(ls_todt,2)
dw_list.Object.t_time.Text  = LeftA(ls_time_from,2) + ':' + RightA(ls_time_from,2) + ' ~~ ' + LeftA(ls_time_to,2) + ':' + RightA(ls_time_to,2)
dw_list.Object.t_nopay.Text = String(ll_nopay)
dw_list.Object.t_num.Text   = ls_num
dw_list.Object.t_svctype.Text = Trim(dw_cond.Object.compute_svctype[1])
dw_list.Object.t_sacnum.Text = ls_sacnum


If dw_list.RowCount() = 0 Then
	f_msg_info(1000, Title, "")
End If

dw_list.setredraw(True)
SetPointer(Arrow!)
end event

on p2w_prt_call_daysum.create
int iCurrent
call super::create
this.dw_tmp=create dw_tmp
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_tmp
end on

on p2w_prt_call_daysum.destroy
call super::destroy
destroy(this.dw_tmp)
end on

event ue_init();call super::ue_init;ii_orientation = 2
ib_margin = false
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event open;call super::open;String ls_ref_desc


end event

event ue_reset();call super::ue_reset;dw_cond.Object.time_from[1] = Time(00,00,00)
dw_cond.Object.time_to[1]   = Time(23,59,59)
dw_cond.Object.nopay[1]     = 0
end event

type dw_cond from w_a_print`dw_cond within p2w_prt_call_daysum
event ue_saveas_int ( )
integer y = 48
integer width = 2734
integer height = 376
string dataobject = "p2dw_cnd_prt_call_daysum"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;
Choose Case dwo.name
	Case "n011", "n016", "n017", "n19", "n010", "n018"
		If data = "Y" Then
			dw_cond.Object.netc[1] = 'N'
		End If
		
	Case "n2", "n3", "n4", "n5", "n6"
		If data = "Y" Then
			dw_cond.Object.netc[1] = 'N'
		End If
		
	Case "netc"
		If data = "Y" Then
		
			dw_cond.Object.n011[1] = 'N'
			dw_cond.Object.n016[1] = 'N'
			dw_cond.Object.n017[1] = 'N'
			dw_cond.Object.n19[1]  = 'N'
			dw_cond.Object.n010[1] = 'N'
			dw_cond.Object.n018[1] = 'N'
			dw_cond.Object.n2[1]   = 'N'
			dw_cond.Object.n3[1]   = 'N'
			dw_cond.Object.n4[1]   = 'N'
			dw_cond.Object.n5[1]   = 'N'
			dw_cond.Object.n6[1]   = 'N'
					
		End If
End Choose

Return 0
			
end event

type p_ok from w_a_print`p_ok within p2w_prt_call_daysum
integer x = 2949
integer y = 64
end type

type p_close from w_a_print`p_close within p2w_prt_call_daysum
integer x = 2949
integer y = 176
end type

type dw_list from w_a_print`dw_list within p2w_prt_call_daysum
integer y = 472
integer width = 3241
integer height = 1156
string dataobject = "p2dw_prt_call_daysum"
end type

type p_1 from w_a_print`p_1 within p2w_prt_call_daysum
end type

type p_2 from w_a_print`p_2 within p2w_prt_call_daysum
end type

type p_3 from w_a_print`p_3 within p2w_prt_call_daysum
end type

type p_5 from w_a_print`p_5 within p2w_prt_call_daysum
end type

type p_6 from w_a_print`p_6 within p2w_prt_call_daysum
end type

type p_7 from w_a_print`p_7 within p2w_prt_call_daysum
end type

type p_8 from w_a_print`p_8 within p2w_prt_call_daysum
end type

type p_9 from w_a_print`p_9 within p2w_prt_call_daysum
end type

type p_4 from w_a_print`p_4 within p2w_prt_call_daysum
end type

type gb_1 from w_a_print`gb_1 within p2w_prt_call_daysum
end type

type p_port from w_a_print`p_port within p2w_prt_call_daysum
end type

type p_land from w_a_print`p_land within p2w_prt_call_daysum
end type

type gb_cond from w_a_print`gb_cond within p2w_prt_call_daysum
integer width = 2793
integer height = 444
end type

type p_saveas from w_a_print`p_saveas within p2w_prt_call_daysum
end type

type dw_tmp from u_d_base within p2w_prt_call_daysum
boolean visible = false
integer x = 539
integer y = 1776
integer width = 2706
integer height = 72
integer taborder = 11
boolean bringtotop = true
string dataobject = "p2dw_prt_call_daysum"
end type

