$PBExportHeader$b5w_reg_reqpay_mod.srw
$PBExportComments$[ceusee] 미처리입금조정반영
forward
global type b5w_reg_reqpay_mod from w_a_reg_m
end type
end forward

global type b5w_reg_reqpay_mod from w_a_reg_m
integer height = 1912
end type
global b5w_reg_reqpay_mod b5w_reg_reqpay_mod

type variables
//Messeage for messagebox
String is_msg_text
String is_msg_process

end variables

forward prototypes
public function integer wfi_get_payid (string as_payid)
public function long wfi_set_reqpay ()
end prototypes

public function integer wfi_get_payid (string as_payid);String ls_payid, ls_paynm

ls_payid = as_payid

If IsNull(ls_payid) Then ls_payid = " "

Select Customernm
  Into :ls_paynm
  From Customerm
 Where customerid = :ls_payid;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Pay Id(wfi_get_payid)")
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	Return -1
End If

dw_cond.object.paynm[1] = ls_paynm

Return 0

end function

public function long wfi_set_reqpay ();String ls_paytype, ls_errmsg, ls_pgm_id, ls_check_yn, ls_payid
Double lb_seqno  , lb_count
Long   ll_rc     , ll_Row   , ll_return
Int    li_cnt

If dw_detail.RowCount() = 0 Then Return 0

ls_errmsg = space(256)
ls_pgm_id = gs_pgm_id[gi_open_win_no]
ls_payid 	= trim(dw_cond.Object.payid[1])
ll_return = -1

If IsNull(ls_paytype) Then ls_paytype = ""

For li_cnt = 1 to dw_detail.RowCount()
	If dw_detail.object.check_yn[li_cnt] = '1' Then
		lb_seqno 		= dw_detail.object.seqno[li_cnt]
		ls_paytype 		= dw_detail.object.paytype[li_cnt]
		If IsNull(lb_seqno) Then lb_seqno = 0
		
		//처리부분...수동 입금 반영
		//SQLCA.B5REQPAY2DTL(ls_paytype, gs_user_id, ls_pgm_id, ll_return, ls_errmsg,lb_count) 
		//
		//SQLCA.B5REQPAY2DTL(gs_user_id, ls_pgm_id, ll_return, ls_errmsg,lb_count) 
		// 2007-7-30 변경
		SQLCA.B5REQPAY2DTL_PAYID(ls_payid, gs_user_id, ls_pgm_id, ll_return, ls_errmsg,lb_count) 
		
		If SQLCA.SQLCode < 0 Then		//For Programer
			MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText,StopSign!)
			Return  -1
		
		ElseIf ll_return = -1 Then	//For User
			MessageBox(This.Title, ls_errmsg, StopSign!)
		End If
		
		If ll_return <> 0 Then	//실패
			Return -1
		Else				//성공
			//Return 0
		End If
	End If
Next

Return 0

end function

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b5w_reg_reqpay_mod
	Desc.	: 미입금 처리 반영
	Date	: 2002.12.31
	Ver.	: 1.0
	Porgramer : Choi Bo Ra(ceusee)
--------------------------------------------------------------------------*/
Long ll_rc
Int  li_cnt
String ls_ref_desc, ls_format

//금액 format 맞춘다.
ls_format = fs_get_control("B5", "H200", ls_ref_desc)
If ls_format = "1" Then
	dw_detail.object.payamt.Format = "#,##0.0"	
ElseIf ls_format = "2" Then
	dw_detail.object.payamt.Format = "#,##0.00"	
Else
	dw_detail.object.payamt.Format = "#,##0"	
End If



This.TriggerEvent("ue_ok")

ll_rc = dw_detail.RowCount()
If ll_rc = 0 Then Return 0

For li_cnt = 1 to ll_rc
	dw_detail.object.check_yn[li_cnt] = '1'
Next

end event

event ue_ok();call super::ue_ok;String ls_where  , ls_transdt
String ls_date_fr, ls_date_to, ls_paytype, ls_payid, ls_trcod
Date ld_date_to, ld_date_fr
Long   ll_rc
Int    li_rc
String ls_ref_desc

//선수금 코드
String ls_paycod, ls_tmp, ls_name[]

//선수금 코드
ls_tmp= fs_get_control("B5", "I101", ls_ref_desc)
fi_cut_string(ls_tmp, ";", ls_name[])
ls_paycod =ls_name[5] 

ls_payid = dw_cond.object.payid[1]
ls_date_fr = String(dw_cond.object.paydt_fr[1], "yyyymmdd")
ls_date_to = String(dw_cond.object.paydt_to[1], "yyyymmdd")
ls_trcod = dw_cond.object.trcod[1]
ls_paytype = dw_cond.object.paytype[1]
ls_transdt = String(dw_cond.object.transdt[1], "yyyymmdd")
ld_date_fr = dw_cond.object.paydt_fr[1]
ld_date_to = dw_cond.object.paydt_to[1]


If IsNull(ls_payid) Then ls_payid = ""
If IsNull(ls_date_fr) Then ls_date_fr = ""
If IsNull(ls_date_to) Then ls_date_to = ""
If IsNull(ls_trcod) Then ls_trcod = ""
If IsNull(ls_paytype) Then ls_paytype = ""
If IsNull(ls_transdt) Then ls_transdt = ""

If ls_date_fr <> "" and ls_date_to <> "" Then
	li_rc = fi_chk_frto_day(ld_date_fr, ld_date_to)
	If li_rc = - 1 Then
		f_msg_usr_err(201, title, "Payment Date")
		Return
	End If
End If

ls_where = ""
If ls_payid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " reqpay.payid = '" + ls_payid + "' "
End If

If ls_date_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(reqpay.paydt, 'yyyymmdd') >= '" + ls_date_fr + "' "
End If

If ls_date_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(reqpay.paydt, 'yyyymmdd') <= '" + ls_date_to + "' "
End If

If ls_trcod <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " reqpay.trcod ='" + ls_trcod + "' "
End If

If ls_paytype <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " reqpay.paytype = '" + ls_paytype + "' "
End If

If ls_transdt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(reqpay.transdt, 'yyyymmdd') = '" + ls_transdt + "' "
End If

dw_detail.is_where = ls_where
ll_rc = dw_detail.Retrieve(ls_paycod) 



If ll_rc < 0 Then
	f_msg_usr_err(2100, Title, "Detail : Retrieve()")
	Return
End If

p_ok.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return
end event

event type integer ue_reset();Constant Int LI_ERROR = -1
Int li_rc

dw_detail.AcceptText()

If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return LI_ERROR
End If

p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_detail.Reset()
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()

Return 0

end event

event type integer ue_save();Constant Int LI_ERROR = -1
Long ll_rc

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

ll_rc = dw_detail.Update()
If ll_rc < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If

	f_msg_info(3010,This.Title,"Save")
	Return LI_ERROR
Else
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	
	//프로시저 Call
	ll_rc = -1
	ll_rc = wfi_set_reqpay()
	If ll_rc = 0 Then
		f_msg_info(3000,This.Title,"Save")
		This.TriggerEvent("ue_ok")
	Else
		Return LI_ERROR
	End If
End If



Return 0

   


end event

on b5w_reg_reqpay_mod.create
call super::create
end on

on b5w_reg_reqpay_mod.destroy
call super::destroy
end on

event type integer ue_extra_save();call super::ue_extra_save;Long   ll_rc
Int    li_cnt, li_count
String ls_prc_yn, ls_payid, ls_paydt
Double lb_payamt

If dw_detail.RowCount() = 0 Then Return 0 

For li_cnt = 1 to  dw_detail.RowCount()
	ls_prc_yn = dw_detail.object.prc_yn[li_cnt]
	
	If ls_prc_yn = 'E' Then
		ls_payid = dw_detail.object.payid[li_cnt]
		ls_paydt = String(dw_detail.object.paydt[li_cnt], "yyyymmdd")
		lb_payamt = dw_detail.object.payamt[li_cnt]
		
		If IsNull(ls_payid) Then ls_payid = ""
		If IsNull(ls_paydt) Then ls_paydt = ""
		If IsNull(lb_payamt) Then lb_payamt = 0
		
		If ls_payid = "" Then
			f_msg_usr_err(200, Title, "Pay Id")
			dw_detail.SetColumn("payid")
			dw_detail.SetFocus()
			Return -2
		Else
			Select count(*)
			Into :li_count 
			From billingInfo
			Where customerid = :ls_payid;
			
			If li_count = 0 Then
				f_msg_usr_err(210, Title, "Pay Id")
				dw_detail.SetRow(li_cnt)
				dw_detail.ScrollToRow(li_cnt)
				dw_detail.SetColumn("payid")
				Return -2
			End If
		End If
		
		If ls_paydt = "" Then
			f_msg_usr_err(200, Title, "Payment Date")
			dw_detail.SetColumn("paydt")
			dw_detail.SetFocus()
			Return -2
		End If

		If lb_payamt = 0 Then
			f_msg_usr_err(200, Title, "Amount")
			dw_detail.SetColumn("payamt")
			dw_detail.SetFocus()
			Return -2
		End If

	End If   //prc_yn = "E"
	
	
	
Next

Return 0

end event

type dw_cond from w_a_reg_m`dw_cond within b5w_reg_reqpay_mod
integer width = 2290
integer height = 268
string dataobject = "b5d_cnd_reg_reqpay_mod"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;Integer li_rc
Choose Case dwo.Name
	Case "payid"
		li_rc = wfi_get_payid(data)
		If li_rc < 0 Then
			dw_cond.object.payid[1] = ""
			dw_cond.object.paynm[1] = ""
			dw_cond.SetColumn("payid")
			Return 0
		End IF
End Choose
end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
			This.Object.payid[1] = iu_cust_help.is_data2[1]
			This.Object.paynm[1] = iu_cust_help.is_data2[2]
		End If
End Choose

Return 0 
end event

event dw_cond::ue_init();call super::ue_init;idwo_help_col[1] = Object.payid
is_help_win[1] = "b5w_hlp_paymst"
is_data[1] = "CloseWithReturn"

end event

type p_ok from w_a_reg_m`p_ok within b5w_reg_reqpay_mod
integer x = 2528
integer y = 68
end type

type p_close from w_a_reg_m`p_close within b5w_reg_reqpay_mod
integer x = 2528
integer y = 192
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b5w_reg_reqpay_mod
integer width = 2373
integer height = 344
end type

type p_delete from w_a_reg_m`p_delete within b5w_reg_reqpay_mod
boolean visible = false
end type

type p_insert from w_a_reg_m`p_insert within b5w_reg_reqpay_mod
boolean visible = false
end type

type p_save from w_a_reg_m`p_save within b5w_reg_reqpay_mod
integer x = 91
integer y = 1664
end type

type dw_detail from w_a_reg_m`dw_detail within b5w_reg_reqpay_mod
integer x = 5
integer y = 364
string dataobject = "b5d_reg_reqpay"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within b5w_reg_reqpay_mod
integer x = 425
integer y = 1664
end type

