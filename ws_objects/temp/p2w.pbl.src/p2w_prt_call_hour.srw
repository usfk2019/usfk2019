$PBExportHeader$p2w_prt_call_hour.srw
$PBExportComments$[kem] 시간대별통화현황
forward
global type p2w_prt_call_hour from w_a_print
end type
end forward

global type p2w_prt_call_hour from w_a_print
integer width = 3150
end type
global p2w_prt_call_hour p2w_prt_call_hour

type variables
String is_svctype
end variables

forward prototypes
public function integer wf_inq_cdr (string as_yyyymmdd)
end prototypes

public function integer wf_inq_cdr (string as_yyyymmdd);//**   Argument : as_yyyymmdd  //일자

String ls_sql, ls_sql1, ls_sql2, ls_sql3, ls_sql4, ls_type, ls_where, ls_where1, ls_timefrom, ls_timeto
String ls_table, ls_table1, ls_group_sql, ls_sysdate, ls_sum_sql, ls_sum_sql1, ls_sum_group, ls_sum_group1
Integer li_count

If is_svctype <> "" Then
	ls_type = 'PRE_CDR'
End If

ls_table = ls_type + as_yyyymmdd
ls_sysdate = String(fdt_get_dbserver_now(), 'YYYYMMDD')

If as_yyyymmdd <> ls_sysdate Then
	ls_table1 = ls_type + String(fd_date_next(dw_cond.Object.yyyymmdd[1], 1), 'YYYYMMDD')
End If

// 테이블 찾기
Select count(tname)
Into :li_count
from tab where tabtype = 'TABLE'
and  tname in (:ls_table, :ls_table1) ;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, " Select Tab Error")
   Return -1
End If

If li_count = 0 Then
	f_msg_info(1000, Title , "")
	Return -1
End If

ls_sql = " SELECT NVL(A.RTIME, B.RTIME1), " + &
			"	      NVL(A.FLAG, '1'),       " + &
			"	      NVL(A.BILCNT, 0),       " + &     
			"	      NVL(A.BILTIME, 0),      " + &
			"	      NVL(A.BILAMT, 0),       " + &
			"  		NVL(B.RTIME1, A.RTIME), " + &
			"			NVL(B.FLAG1, '9'),      " + &
			"			NVL(B.BILCNT1, 0),      " + &
			"			NVL(B.BILTIME1, 0),     " + &
			"			NVL(B.BILAMT1,0)        " + &
			"   FROM                         "
			
ls_sum_sql = " ( SELECT RTIME,                " + &
             "          FLAG,                 " + &
				 "          SUM(BILCNT) BILCNT,   " + &
				 "          SUM(BILTIME) BILTIME, " + &
				 "          SUM(BILAMT) BILAMT    " + &
				 "     FROM                       "
				 
ls_sum_group = " GROUP BY RTIME, FLAG "

ls_sum_sql1 = " ( SELECT RTIME1,                 " + &
              "          FLAG1,                  " + &
				  "          SUM(BILCNT1) BILCNT1,   " + &
				  "          SUM(BILTIME1) BILTIME1, " + &
				  "          SUM(BILAMT1) BILAMT1    " + &
				  "     FROM                         "
				  
ls_sum_group1 = " GROUP BY RTIME1, FLAG1 "
				 
			
ls_sql1 = "(SELECT TO_CHAR(RTIME, 'HH24') RTIME,     " + &
			"		   '1' FLAG,                          " + &
			"		   COUNT(RTIME) BILCNT,               " + &
			"		   SUM(NVL(BILTIME, 0)) BILTIME,      " + &
			"		   SUM(NVL(BILAMT, 0)) BILAMT         " + &
			"	 FROM " + ls_table + "                   " + &
			"  WHERE SVCTYPE = '" + is_svctype + "'     " + &
			"    AND FLAG <> '9'                        " + &
			"    AND TO_CHAR(RTIME, 'YYYYMMDD') = '" + as_yyyymmdd + "' "
			
ls_sql3 = " SELECT TO_CHAR(RTIME, 'HH24') RTIME,     " + &
			"		   '1' FLAG,                          " + &
			"		   COUNT(RTIME) BILCNT,               " + &
			"		   SUM(NVL(BILTIME, 0)) BILTIME,      " + &
			"		   SUM(NVL(BILAMT, 0)) BILAMT         " + &
			"	 FROM " + ls_table1 + "                  " + &
			"  WHERE SVCTYPE = '" + is_svctype + "'     " + &
			"    AND FLAG <> '9'                        " + &
			"    AND TO_CHAR(RTIME, 'YYYYMMDD') = '" + as_yyyymmdd + "' "			
			
ls_sql2 = "(SELECT TO_CHAR(RTIME, 'HH24') RTIME1,    " + &
			"		   '9' FLAG1,                         " + &
			"		   COUNT(RTIME) BILCNT1,              " + &
			"		   SUM(NVL(BILTIME, 0)) BILTIME1,     " + &
			"		   SUM(NVL(BILAMT, 0)) BILAMT1        " + &
			"	 FROM " + ls_table + "                   " + &
			"  WHERE SVCTYPE = '" + is_svctype + "'     " + &
			"    AND FLAG = '9'                         " + &
			"    AND TO_CHAR(RTIME, 'YYYYMMDD') = '" + as_yyyymmdd + "' "
			
ls_sql4 = " SELECT TO_CHAR(RTIME, 'HH24') RTIME1,    " + &
			"		   '9' FLAG1,                         " + &
			"		   COUNT(RTIME) BILCNT1,              " + &
			"		   SUM(NVL(BILTIME, 0)) BILTIME1,     " + &
			"		   SUM(NVL(BILAMT, 0)) BILAMT1        " + &
			"	 FROM " + ls_table1 + "                  " + &
			"  WHERE SVCTYPE = '" + is_svctype + "'     " + &
			"    AND FLAG = '9'                         " + &
			"    AND TO_CHAR(RTIME, 'YYYYMMDD') = '" + as_yyyymmdd + "' "
			
ls_group_sql = " GROUP BY TO_CHAR(RTIME, 'HH24'), DECODE(FLAG, '9', '9', '1') "
ls_where1    = " WHERE A.RTIME = B.RTIME1 "

ls_timefrom  = String(dw_cond.Object.time_from[1], 'HHMM')
ls_timeto    = String(dw_cond.Object.time_to[1], 'HHMM')

If IsNull(ls_timefrom) Or ls_timefrom = "" Then ls_timefrom = "0000"

//기본 Where 문
ls_where = " "
If ls_timefrom <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(rtime, 'HH24MM') >= '" + ls_timefrom +  "'"
End if

If ls_timeto <> "" then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(rtime, 'HH24MM') <= '" + ls_timeto + "'"
End if

If ls_table1 <> "" Then
	ls_sql = ls_sql + ls_sum_sql + ls_sql1 + ls_where + ls_group_sql + ' UNION ALL ' + ls_sql3 + ls_where + ls_group_sql + ')' + ls_sum_group + ') A,' &
				+ ls_sum_sql1 + ls_sql2 + ls_where + ls_group_sql + ' UNION ALL ' + ls_sql4 + ls_where + ls_group_sql + ')' + ls_sum_group1 + ') B ' + ls_where1
Else
	ls_sql = ls_sql + ls_sql1 + ls_where + ls_group_sql + ' ) A,' + &
	         + ls_sql2 + ls_where + ls_group_sql + ' ) B ' + ls_where1
End If
//messagebox('1', ls_sql)
//Clipboard (ls_sql )

dw_list.SetSqlSelect(ls_sql)

//조회
dw_list.Retrieve()

Return 1
end function

event ue_ok();call super::ue_ok;//조회
String ls_yyyymmdd, ls_time_from, ls_time_to

//필수입력사항 check
ls_yyyymmdd  = String(dw_cond.Object.yyyymmdd[1], "yyyymmdd")
ls_time_from = String(dw_cond.Object.time_from[1], "hhmm")
ls_time_to   = String(dw_cond.object.time_to[1], "hhmm")

If IsNull(ls_yyyymmdd) Then ls_yyyymmdd = ""				
If IsNull(ls_time_from) Then ls_time_from = ""				
If IsNull(ls_time_to) Then ls_time_to = ""

If ls_yyyymmdd = "" Then
	f_msg_info(200, Title, "일자")
	dw_cond.SetFocus()
	dw_cond.setColumn("yyyymmdd")
	Return 
End If


SetPointer(HourGlass!)
dw_list.setredraw(False)

If wf_inq_cdr(ls_yyyymmdd) = -1 Then
	dw_list.setredraw(True)
	SetPointer(Arrow!)
	return 
End if

dw_list.Object.t_date.Text = LeftA(ls_yyyymmdd,4) + '-' + MidA(ls_yyyymmdd,5,2) + '-' + RightA(ls_yyyymmdd,2)
dw_list.Object.t_time.Text = LeftA(ls_time_from,2) + ':' + RightA(ls_time_from,2) + ' ~~ ' + LeftA(ls_time_to,2) + ':' + RightA(ls_time_to,2)


If dw_list.rowcount() = 0 Then
	f_msg_info(1000, Title, "")
End If

dw_list.setredraw(True)
SetPointer(Arrow!)
end event

on p2w_prt_call_hour.create
call super::create
end on

on p2w_prt_call_hour.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 2
ib_margin = false
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event open;call super::open;String ls_ref_desc

//선불카드 서비스타입
is_svctype = fs_get_control('P0', 'P100', ls_ref_desc)
end event

event ue_reset();call super::ue_reset;dw_cond.Object.time_from[1] = Time(00,00,00)
dw_cond.Object.time_to[1]   = Time(23,59,59)
end event

type dw_cond from w_a_print`dw_cond within p2w_prt_call_hour
event ue_saveas_int ( )
integer y = 48
integer width = 1225
integer height = 240
string dataobject = "p2dw_cnd_prt_call_hour"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;String ls_pid

If dwo.name = "contno" Then
	If data <> "" Then
		
		SELECT PID
		  INTO :ls_pid
		  FROM P_CARDMST
		 WHERE CONTNO = :data ;
		 
		If SQLCA.SQLCode < 0 Then
			f_msg_usr_err(9000, is_title, "P_CARDMST SELECT Error")
			Return -1
		ElseIf SQLCA.SQLCode = 100 Then
			f_msg_info(9000, is_title, "해당하는 관리번호가 없습니다.")
			dw_cond.Object.contno[1] = ""
			dw_cond.SetFocus()
			dw_cond.SetColumn("contno")
			Return -1
		End If
		
		dw_cond.Object.pid[1] = ls_pid
				
	End If
End If

Return 0
			
end event

type p_ok from w_a_print`p_ok within p2w_prt_call_hour
integer x = 1445
integer y = 64
end type

type p_close from w_a_print`p_close within p2w_prt_call_hour
integer x = 1751
integer y = 64
end type

type dw_list from w_a_print`dw_list within p2w_prt_call_hour
integer y = 336
integer width = 3035
integer height = 1304
string dataobject = "p2dw_prt_call_hour"
end type

type p_1 from w_a_print`p_1 within p2w_prt_call_hour
end type

type p_2 from w_a_print`p_2 within p2w_prt_call_hour
end type

type p_3 from w_a_print`p_3 within p2w_prt_call_hour
end type

type p_5 from w_a_print`p_5 within p2w_prt_call_hour
end type

type p_6 from w_a_print`p_6 within p2w_prt_call_hour
end type

type p_7 from w_a_print`p_7 within p2w_prt_call_hour
end type

type p_8 from w_a_print`p_8 within p2w_prt_call_hour
end type

type p_9 from w_a_print`p_9 within p2w_prt_call_hour
end type

type p_4 from w_a_print`p_4 within p2w_prt_call_hour
end type

type gb_1 from w_a_print`gb_1 within p2w_prt_call_hour
end type

type p_port from w_a_print`p_port within p2w_prt_call_hour
end type

type p_land from w_a_print`p_land within p2w_prt_call_hour
end type

type gb_cond from w_a_print`gb_cond within p2w_prt_call_hour
integer width = 1285
integer height = 308
end type

type p_saveas from w_a_print`p_saveas within p2w_prt_call_hour
end type

