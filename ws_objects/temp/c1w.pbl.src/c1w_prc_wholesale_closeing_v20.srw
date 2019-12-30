$PBExportHeader$c1w_prc_wholesale_closeing_v20.srw
$PBExportComments$[ohj] 홀세일마감재계산 v20
forward
global type c1w_prc_wholesale_closeing_v20 from w_a_prc
end type
end forward

global type c1w_prc_wholesale_closeing_v20 from w_a_prc
integer width = 1947
integer height = 1196
end type
global c1w_prc_wholesale_closeing_v20 c1w_prc_wholesale_closeing_v20

type variables
Long il_unitrownum, il_commitrownum
end variables

on c1w_prc_wholesale_closeing_v20.create
call super::create
end on

on c1w_prc_wholesale_closeing_v20.destroy
call super::destroy
end on

event type integer ue_process();
String ls_errmsg,ls_yyyymmdd_fr,ls_yyyymmdd_to,ls_null,ls_CalcType,ls_customerid
Long ll_return
double lb_count

ls_calcType = '1' // 홀세일마감재처리flag 
ll_return = -1
ls_errmsg = space(256)
//ls_pgm_id = iu_cust_msg.is_pgm_id
//ls_chargedt = trim(dw_input.Object.chargedt[1])
ls_yyyymmdd_fr = String(dw_input.Object.yyyymmdd_fr[1], "yyyymmdd")
ls_yyyymmdd_to = String(dw_input.Object.yyyymmdd_to[1], "yyyymmdd")
ls_customerid  = trim(dw_input.Object.customerid[1])

If ls_customerid = ''Then
    setnull(ls_customerid)
End If

//처리부분...
SQLCA.WHOLESALE_CLOSEING(ls_yyyymmdd_fr, ls_yyyymmdd_to, ls_calctype, ls_customerid, il_unitrownum, il_commitrownum, ll_return, ls_errmsg, lb_count)
If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	ll_return = -1
ElseIf ll_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg)
End If


If ll_return <> 0 Then	//실패
	is_msg_process = "Fail"
	Return -1
Else				//성공
	is_msg_process = "Count: " + String(lb_count, "#,##0") + " 건"
	Return 0
End If


end event

event type integer ue_input();call super::ue_input;String ls_yyyymmdd_fr, ls_yyyymmdd_to,ls_sysdate

ls_sysdate = string(date(fdt_get_dbserver_now()),'yyyymmdd') 
ls_yyyymmdd_fr = String(dw_input.Object.yyyymmdd_fr[1], "yyyymmdd")
ls_yyyymmdd_to = String(dw_input.Object.yyyymmdd_to[1], "yyyymmdd")

If ls_yyyymmdd_fr = "" Then
	f_msg_usr_err(200, This.Title, "재마감일자 Fr")
	dw_input.SetFocus()
	dw_input.SetColumn("yyyymmdd_fr")
	Return -1
End If

If ls_yyyymmdd_to = "" Then
	f_msg_usr_err(200, This.Title, "재마감일자 To")
	dw_input.SetFocus()
	dw_input.SetColumn("yyyymmdd_to")
	Return -1
End If

If ls_yyyymmdd_fr > ls_yyyymmdd_to or ls_yyyymmdd_to >= ls_sysdate Then
	f_msg_info(9000, This.Title, "재마감일자(To)를 확인하세요")
	dw_input.SetFocus()
    dw_input.SetColumn("yyyymmdd_to")
	Return -1
End If

Return 0


end event

event open;call super::open;String ls_module, ls_ref_no, ls_ref_desc, ls_date[], ls_temp
//String ls_yyyymmdd
//
//ls_module = "B5"
//ls_ref_no = "A101" 
//ls_ref_desc = ""
//ls_yyyymmdd = fs_get_control(ls_module, ls_ref_no, ls_ref_desc)
//
//If IsNull(ls_yyyymmdd) Then Return
//If ls_yyyymmdd <> "" Then
//    dw_input.Object.yyyymmdd_fr[1] = fd_date_next(date(mid(ls_yyyymmdd,1,4) + '-' + mid(ls_yyyymmdd,5,2) + '-' + mid(ls_yyyymmdd,7,2)),1)
//	 dw_input.Object.yyyymmdd_to[1] = fd_date_next(date(mid(ls_yyyymmdd,1,4) + '-' + mid(ls_yyyymmdd,5,2) + '-' + mid(ls_yyyymmdd,7,2)),1)
//	
//End If;
//
//p_ok.SetFocus()
//
// 

//프로시저 row 수, commit수
ls_temp = ""
ls_temp = fs_get_control('C1','C232', ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", ls_date[])

il_unitrownum   = Long(ls_date[1])
il_commitrownum = Long(ls_date[2])

dw_input.Object.yyyymmdd_fr[1] = fd_date_pre(date(fdt_get_dbserver_now()),1)
dw_input.Object.yyyymmdd_to[1] = fd_date_pre(date(fdt_get_dbserver_now()),1)



end event

type p_ok from w_a_prc`p_ok within c1w_prc_wholesale_closeing_v20
integer x = 1568
integer y = 56
end type

type dw_input from w_a_prc`dw_input within c1w_prc_wholesale_closeing_v20
integer y = 64
integer width = 1358
integer height = 220
string dataobject = "c1dw_cnd_prc_wholesale_closeing_v20"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within c1w_prc_wholesale_closeing_v20
integer y = 804
integer width = 1856
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within c1w_prc_wholesale_closeing_v20
integer y = 340
integer width = 1856
end type

type ln_up from w_a_prc`ln_up within c1w_prc_wholesale_closeing_v20
integer beginx = 18
integer beginy = 328
integer endx = 1824
integer endy = 328
end type

type ln_down from w_a_prc`ln_down within c1w_prc_wholesale_closeing_v20
integer beginy = 1084
integer endx = 1838
integer endy = 1084
end type

type p_close from w_a_prc`p_close within c1w_prc_wholesale_closeing_v20
integer x = 1568
integer y = 176
end type

type gb_cond from w_a_prc`gb_cond within c1w_prc_wholesale_closeing_v20
integer width = 1426
integer height = 304
end type

