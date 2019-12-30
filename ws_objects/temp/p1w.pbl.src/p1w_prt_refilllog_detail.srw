$PBExportHeader$p1w_prt_refilllog_detail.srw
$PBExportComments$[victory] 충전명세서(상세)
forward
global type p1w_prt_refilllog_detail from w_a_print
end type
end forward

global type p1w_prt_refilllog_detail from w_a_print
integer width = 3282
integer height = 2148
end type
global p1w_prt_refilllog_detail p1w_prt_refilllog_detail

type variables
//e03u_cust_db_app iu_db01
end variables

on p1w_prt_refilllog_detail.create
call super::create
end on

on p1w_prt_refilllog_detail.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Integer li_return
Long ll_row
String ls_where, ls_refill_date1, ls_refill_date2
String ls_cardid1, ls_cardid2, ls_contno1, ls_contno2
String ls_lflag, ls_markid
String ls_salman, ls_invno
Date ld_frdate, ld_todate

ls_refill_date1 = String(dw_cond.Object.refill_date1[1],"yyyymmdd")
If IsNull(ls_refill_date1) Then ls_refill_date1 = ""
ls_refill_date2 = String(dw_cond.Object.refill_date2[1],"yyyymmdd")
If IsNull(ls_refill_date2) Then ls_refill_date2 = ""


ls_cardid1 = dw_cond.Object.cardid1[1]
If IsNull(ls_cardid1) Then ls_cardid1 = ""

ls_contno1 = dw_cond.Object.contno1[1]
If IsNull(ls_contno1) Then ls_contno1 = ""
ls_contno2 = dw_cond.Object.contno2[1]
If IsNull(ls_contno2) Then ls_contno2 = ""

ls_lflag = dw_cond.Object.lflag[1]
If IsNull(ls_lflag) Then ls_lflag = ""

ls_markid = dw_cond.Object.marketid[1]
If IsNull(ls_markid) Then ls_markid = ""

ls_salman = dw_cond.Object.salman[1]
If IsNull(ls_salman) Then ls_salman = ""

If ls_refill_date1 <> "" And ls_refill_date2 <> "" Then 
	ld_frdate = Date(MidA(ls_refill_date1,1,4) + '/' + MidA(ls_refill_date1,5,2) + '/' + MidA(ls_refill_date1,7,2))
	ld_todate = Date(MidA(ls_refill_date2,1,4) + '/' + MidA(ls_refill_date2,5,2) + '/' + MidA(ls_refill_date2,7,2))
	
//	li_return = fi_chk_frto_day(ld_frdate, ld_todate)
//	If li_return <> 0 Then 
	If ls_refill_date1 > ls_refill_date2 Then
		f_msg_usr_err(210, is_title, "충전일자")
		Return
	End If
else
	If ls_cardid1 ="" and ls_contno1 = "" and ls_contno2 = "" and ls_salman = "" and ls_lflag = "" and ls_markid = "" Then
		f_msg_usr_err(200, is_title, "조건중에 하나는 입력하셔야 합니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("cardid1")
		Return
	End If
End If

ls_where = ""

If ls_refill_date1 <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "p_refilllog.refilldt >= to_date('" + ls_refill_date1 + "000000','yyyymmddhh24miss') "
End If

If ls_refill_date2 <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "p_refilllog.refilldt <= to_date('" + ls_refill_date2 + "235959','yyyymmddhh24miss') "
End If

If ls_cardid1 <> ""  Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "p_refilllog.pid like '" + ls_cardid1 + "%'"
End If

If ls_contno1 <> ""  Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "p_refilllog.contno >= '" + ls_contno1 + "'"
End If
If ls_contno2 <> ""  Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "p_refilllog.contno <= '" + ls_contno2 + "'"
End If

If ls_lflag <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "p_refilllog.refill_type = '" + ls_lflag + "'"
End If

If ls_markid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "p_cardmst.priceplan = '" + ls_markid + "'"
End If

If ls_salman <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "p_cardmst.partner_prefix = '" + ls_salman + "'"
End If


dw_list.is_where = ls_where 
ll_row = dw_list.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
   Return
ElseIf ll_row = 0 Then
	f_msg_usr_err(1100, Title, "")
End If
end event

event open;call super::open;//iu_db01 = Create e03u_cust_db_app
//dw_cond.Object.inv_no[1] = "A"
//dw_cond.Object.inv_target[1] = "A"
end event

event close;call super::close;//Destroy iu_db01
end event

event ue_init;call super::ue_init;ii_orientation = 1
ib_margin = false
end event

event ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within p1w_prt_refilllog_detail
integer x = 46
integer y = 48
integer width = 2478
integer height = 284
string dataobject = "p1d_cnd_prt_refilllog_detail"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type p_ok from w_a_print`p_ok within p1w_prt_refilllog_detail
integer x = 2615
end type

type p_close from w_a_print`p_close within p1w_prt_refilllog_detail
integer x = 2917
integer y = 48
end type

type dw_list from w_a_print`dw_list within p1w_prt_refilllog_detail
integer y = 388
integer width = 3163
integer height = 1324
string dataobject = "p1d_prt_refilllog_detail"
end type

type p_1 from w_a_print`p_1 within p1w_prt_refilllog_detail
integer x = 2912
integer y = 1876
end type

type p_2 from w_a_print`p_2 within p1w_prt_refilllog_detail
integer x = 494
integer y = 1876
end type

type p_3 from w_a_print`p_3 within p1w_prt_refilllog_detail
integer x = 2601
integer y = 1876
end type

type p_5 from w_a_print`p_5 within p1w_prt_refilllog_detail
integer x = 1088
integer y = 1876
end type

type p_6 from w_a_print`p_6 within p1w_prt_refilllog_detail
integer x = 1728
integer y = 1876
end type

type p_7 from w_a_print`p_7 within p1w_prt_refilllog_detail
integer x = 1513
integer y = 1876
end type

type p_8 from w_a_print`p_8 within p1w_prt_refilllog_detail
integer x = 1298
integer y = 1876
end type

type p_9 from w_a_print`p_9 within p1w_prt_refilllog_detail
integer x = 791
integer y = 1876
end type

type p_4 from w_a_print`p_4 within p1w_prt_refilllog_detail
end type

type gb_1 from w_a_print`gb_1 within p1w_prt_refilllog_detail
integer x = 37
integer y = 1804
end type

type p_port from w_a_print`p_port within p1w_prt_refilllog_detail
integer x = 82
integer y = 1860
end type

type p_land from w_a_print`p_land within p1w_prt_refilllog_detail
integer x = 242
integer y = 1872
end type

type gb_cond from w_a_print`gb_cond within p1w_prt_refilllog_detail
integer width = 2519
integer height = 352
end type

type p_saveas from w_a_print`p_saveas within p1w_prt_refilllog_detail
integer x = 2290
integer y = 1876
end type

