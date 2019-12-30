$PBExportHeader$w_reg_control_desc.srw
$PBExportComments$Parameter Desc Entry (from w_a_reg_m)
forward
global type w_reg_control_desc from w_a_reg_m
end type
end forward

global type w_reg_control_desc from w_a_reg_m
integer width = 3099
integer height = 1908
end type
global w_reg_control_desc w_reg_control_desc

type variables
String is_pgmid
end variables

on w_reg_control_desc.create
call super::create
end on

on w_reg_control_desc.destroy
call super::destroy
end on

event ue_ok;call super::ue_ok;String ls_where, ls_where_tmp
String ls_module, ls_ref_no, ls_ref_desc
Long ll_row

//입력 조건 처리 부분
ls_module = Trim(String(dw_cond.Object.module[1]))
ls_ref_no = Trim(String(dw_cond.Object.ref_no[1]))
ls_ref_desc = Trim(String(dw_cond.Object.ref_desc[1]))

//에레 처리부분

//Dynamic SQL 처리부분
If ls_module <> "" Then
	ls_where = "module like '" + ls_module + "%'"
End If

If ls_ref_no <> "" Then
	ls_where_tmp = "ref_no like '" + ls_ref_no + "%'"

	If ls_where <> "" Then
		ls_where = ls_where + " and " + ls_where_tmp
	Else
		ls_where = ls_where_tmp
	End If
End If

If ls_ref_desc <> "" Then
	ls_where_tmp = "ref_desc like '" + ls_ref_desc + "%'"

	If ls_where <> "" Then
		ls_where = ls_where + " and " + ls_where_tmp
	Else
		ls_where = ls_where_tmp
	End If
End If

dw_detail.is_where = ls_where

//자료 읽기 및 관련 처리부분
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
End If

end event

event ue_extra_save;//Date ld_now
Integer	li_return
Long		ll_mrow_cnt, ll_row_cnt
String	ls_module, ls_ref_no, ls_ref_desc
String	ls_pgm_id, ls_pgm_item, ls_chg_item, ls_old, ls_new

////***** Record when modified or created ****
//Read today & current time
//iu_cust_db_app.is_caller = "NOW"
//iu_cust_db_app.is_title = This.Title
//
//iu_cust_db_app.uf_prc_db()
//
//If iu_cust_db_app.ii_rc = -1 Then Return
//
//ld_now = Date(iu_cust_db_app.idt_data[1])
//

//Record
ll_row_cnt = dw_detail.RowCount()
Do While ll_mrow_cnt <= ll_row_cnt
	ll_mrow_cnt = dw_detail.GetNextModified(ll_mrow_cnt, Primary!)
	If ll_mrow_cnt > 0 Then
//		dw_detail.Object.reg_dt[ll_mrow_cnt] = ld_now

		//SYSTEM LOG를 남긴다.(pgm_id, '|', module+':'+ref_no+' '+ref_desc)
		ls_module = Trim(dw_detail.Object.module[ll_mrow_cnt])
		ls_ref_no = Trim(dw_detail.Object.ref_no[ll_mrow_cnt])
		ls_ref_desc = Trim(dw_detail.Object.ref_desc[ll_mrow_cnt])
		ls_old = Trim(dw_detail.Object.ref_content.Primary.Original[ll_mrow_cnt])
		ls_new = Trim(dw_detail.Object.ref_content.Primary.Current[ll_mrow_cnt])

		If IsNull(ls_module) Then ls_module = ""
		If IsNull(ls_ref_no) Then ls_ref_no = ""
		If IsNull(ls_ref_desc) Then ls_ref_desc = ""
		If IsNull(ls_old) Then ls_old = ""
		If IsNull(ls_new) Then ls_new = ""

		ls_pgm_id = is_pgmid
		ls_pgm_item = "|"
		ls_chg_item = ls_module + ":" + ls_ref_no + " " + ls_ref_desc
		li_return = fi_set_systemlog(ls_pgm_id, ls_pgm_item, ls_chg_item, ls_old, ls_new)
		If li_return < 0 Then Return -1
	Else
		ll_mrow_cnt = ll_row_cnt + 1
	End If
Loop

Return 0

end event

event open;call super::open;is_pgmid = iu_cust_msg.is_pgm_id

end event

type dw_cond from w_a_reg_m`dw_cond within w_reg_control_desc
integer x = 46
integer y = 52
integer width = 1984
integer height = 208
string dataobject = "d_cnd_control_desc"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within w_reg_control_desc
integer x = 2231
integer y = 44
end type

type p_close from w_a_reg_m`p_close within w_reg_control_desc
integer x = 2533
integer y = 44
end type

type gb_cond from w_a_reg_m`gb_cond within w_reg_control_desc
integer width = 2080
integer height = 272
end type

type p_delete from w_a_reg_m`p_delete within w_reg_control_desc
integer x = 338
integer y = 1676
end type

type p_insert from w_a_reg_m`p_insert within w_reg_control_desc
integer x = 46
integer y = 1672
end type

type p_save from w_a_reg_m`p_save within w_reg_control_desc
integer x = 635
integer y = 1676
end type

type dw_detail from w_a_reg_m`dw_detail within w_reg_control_desc
integer y = 288
integer width = 2999
integer height = 1356
string dataobject = "d_reg_control_desc"
end type

type p_reset from w_a_reg_m`p_reset within w_reg_control_desc
integer x = 1152
integer y = 1676
end type

