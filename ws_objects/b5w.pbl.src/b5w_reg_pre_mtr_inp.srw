$PBExportHeader$b5w_reg_pre_mtr_inp.srw
$PBExportComments$[islim] 선수금입금등록
forward
global type b5w_reg_pre_mtr_inp from w_a_reg_m_sql
end type
end forward

global type b5w_reg_pre_mtr_inp from w_a_reg_m_sql
integer width = 3520
integer height = 2096
end type
global b5w_reg_pre_mtr_inp b5w_reg_pre_mtr_inp

type variables
//NVO For Processing
u_cust_a_db iu_cust_db_prc



//Messeage for messagebox
String is_msg_text
String is_msg_process

//Messeage No. for messagebox
Long il_msg_no

protected privatewrite string is_cur_fr,is_cur_to,is_next_fr,is_next_to
protected privatewrite Integer ii_input_error


String is_paycod, is_format, is_reqdt
Double ib_seq

end variables

forward prototypes
public function integer wfi_get_payid (string as_payid)
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

dw_cond.object.marknm[1] = ls_paynm

Return 0

end function

event open;call super::open;Int li_rc
String ls_ref_desc , ls_tmp, ls_name[]

//금액 format 맞춘다.
is_format = fs_get_control("B5", "H200", ls_ref_desc)
If is_format = "1" Then
	dw_cond.object.payamt.Format = "#,##0.0"
ElseIf is_format = "2" Then
	dw_cond.object.payamt.Format = "#,##0.00"	
Else
	dw_cond.object.payamt.Format = "#,##0"
End If


// Set the Top, Bottom Controls
//idrg_Top = dw_detail


//Change the back color so they cannot be seen.
//ii_WindowTop = idrg_Top.Y
//st_horizontal.BackColor = BackColor
//il_HiddenColor = BackColor

// Call the resize functions
//of_ResizeBars()
//of_ResizePanels()
//
//****kEnn : 이부분이 필요하면 수정사항 반영할 것
//li_rc = This.TriggerEvent("ue_reset")
//****
//ls_paytype = " "

//dw_cond.object.trdt.Protect = 1

ls_tmp= fs_get_control("B5", "I101", ls_ref_desc)
fi_cut_string(ls_tmp, ";", ls_name[])
is_paycod =ls_name[5] 

dw_cond.object.paycod[1] = is_paycod

dw_cond.object.paydt[1] = Date(fdt_get_dbserver_now())

p_ok.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")


end event

event resize;call super::resize;//of_ResizeBars()
//of_ResizePanels()
//
SetRedraw(True)

end event

event type integer ue_save_sql();call super::ue_save_sql;String ls_payid , ls_paydt  , ls_trcod, ls_transdt
String ls_pgm_id, ls_user_id, ls_remark
Long   ll_rc    , ll_seq
Dec    ld_payamt
Int    li_rc 
b5u_dbmgr8 lu_dbmgr



li_rc = -2  //필수 입력 항목 요구
ls_payid = Trim(dw_cond.object.payid[1])
ls_paydt = String(dw_cond.object.paydt[1], 'yyyymmdd')
ld_payamt = dw_cond.object.payamt[1]
ls_trcod = dw_cond.object.trcod[1]
ls_pgm_id = gs_pgm_id[gi_open_win_no]
ls_user_id = gs_user_id
ls_remark = dw_cond.object.remark[1]
ls_transdt = String(dw_cond.object.transdt[1], 'yyyymmdd')


If IsNull(ls_payid) Then ls_payid = ""
If IsNull(ls_paydt) Then ls_paydt = ""
If IsNull(ld_payamt) Then ld_payamt = 0
If IsNull(ls_trcod) Then ls_trcod = ""
If IsNull(ls_transdt) Then ls_transdt = ""

//이체일자 입력 안하면 입금일과 동일.
IF ls_transdt = "" THEN
	ls_transdt = ls_paydt
END IF

If ls_payid = "" Then
	f_msg_usr_err(200, Title, "Pay Id")
	dw_cond.SetColumn("payid")
	Return li_rc
End If

If ls_paydt = "" Then
	f_msg_usr_err(200, Title, "Payment Date")
	dw_cond.SetColumn("paydt")
	Return li_rc
End If

If ls_trcod = "" Then
	f_msg_usr_err(200, Title, "Transaction")
	dw_cond.SetColumn("trcod")
	Return li_rc
End If

If ld_payamt = 0 Then
	f_msg_usr_err(200, Title, "Amount")
	dw_cond.SetColumn("payamt")
	Return li_rc
End If




lu_dbmgr = Create b5u_dbmgr8
//File 생성하러 감
lu_dbmgr.is_title = Title
lu_dbmgr.is_caller = "Insert Reqpay prepay Kilt"
lu_dbmgr.is_data[1] = ls_payid
lu_dbmgr.is_data[2] = is_paycod
lu_dbmgr.is_data[3] = ls_trcod
lu_dbmgr.is_data[4] = ls_paydt
lu_dbmgr.is_data[5] = ls_remark
lu_dbmgr.ic_data[6] = ld_payamt
lu_dbmgr.is_data[7] = ls_transdt


lu_dbmgr.uf_prc_db()
li_rc = lu_dbmgr.ii_rc


If li_rc = -1 Then
	is_msg_process = "Falid Insert"
   Destroy lu_dbmgr
	Return -1
ElseIf li_rc = 0 Then

End If

Destroy lu_dbmgr
Return 0 




end event

event ue_ok();call super::ue_ok;//DataWindowChild ldwc_trdt
String ls_payid, ls_where, ls_paycod
Long   ll_rc


ls_payid = Trim(dw_cond.object.payid[1])
ls_paycod= Trim(dw_cond.object.paycod[1])

If IsNull(ls_payid) Then ls_payid = ""
If ls_payid = "" Then
	f_msg_usr_err(200, Title, "Pay Id")
	dw_cond.SetColumn("payid")
	Return
Else
   ll_rc = wfi_get_payid(ls_payid)  

   If ll_rc < 0 Then
		f_msg_usr_err(201, Title, "Pay Id")
		dw_cond.SetColumn("payid")
		Return
	End If
End If


ls_where = ""
If ls_payid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "PAYID = '" + ls_payid +"'" 
End If

If ls_paycod <> "" Then
	If ls_where <> "" Then ls_where += " AND " 
	ls_where += "PAYTYPE ='" + ls_paycod+ "'"
End If


dw_detail.is_where = ls_where
ll_rc = dw_detail.Retrieve()


p_save.TriggerEvent("ue_enable")


end event

on b5w_reg_pre_mtr_inp.create
call super::create
end on

on b5w_reg_pre_mtr_inp.destroy
call super::destroy
end on

event ue_save();Integer li_return, li_rc, li_tmp
Date ld_tmp
String ls_tmp

If dw_cond.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_cond.SetFocus()
	Return
End If

If dw_detail.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_detail.SetFocus()
	Return
End If

li_return = This.Trigger Event ue_save_sql()
Choose Case li_return
	Case Is < -2
		dw_cond.SetFocus()
	Case -2
		dw_cond.SetFocus()
	Case -1
		//ROLLBACK
		iu_mdb_app.is_title = This.Title
		iu_mdb_app.is_caller = "ROLLBACK"
		iu_mdb_app.uf_prc_db()
		If iu_mdb_app.ii_rc = -1 Then Return
		f_msg_info(3010, This.Title, "Save")
	Case Is >= 0
	
		//성공적이면 commit
		iu_mdb_app.is_title = This.Title
		iu_mdb_app.is_caller = "COMMIT"
		iu_mdb_app.uf_prc_db()
		If iu_mdb_app.ii_rc = -1 Then Return
	
		//Error 
		If li_rc < 0 Then 
			f_msg_info(3010, This.Title, "Save")
		Else	
		   f_msg_info(3000, This.Title, "Save")
		End If
		//초기화
		   SetNull(ld_tmp)
			SetNull(li_tmp)
			SetNull(ls_tmp)
			dw_cond.object.paydt[1] = Date(fdt_get_dbserver_now())
			dw_cond.object.payamt[1] = 0
			dw_cond.object.remark[1] = ls_tmp
			//dw_cond.object.trdt[1] = ld_tmp
			dw_cond.object.trcod[1] = ls_tmp 
			This.TriggerEvent("ue_ok")
End Choose

end event

type dw_cond from w_a_reg_m_sql`dw_cond within b5w_reg_pre_mtr_inp
integer x = 46
integer width = 2386
integer height = 452
string dataobject = "b5d_cnd_reg_pre_mtr_inp"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;dwObject ldwo_payid
ldwo_payid = dw_cond.object.payid

Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
			Object.payid[row] = iu_cust_help.is_data2[1]		//고객번호
			Object.marknm[row] = iu_cust_help.is_data2[2]	//고객명
			//Item Changed Event 발생
			dw_cond.Event ItemChanged(1,ldwo_payid ,iu_cust_help.is_data2[1])
		End If		
End Choose



Return 0

end event

event dw_cond::itemchanged;call super::itemchanged;//DataWindowChild ldwc_trdt
String ls_payid, ls_trcod, ls_customeryn, ls_filter
Date ld_transdt
Int    li_rc

Choose Case dwo.Name
	Case "payid"
		ls_payid = Trim(dw_cond.object.payid[1])
		
		If IsNull(ls_payid) Then ls_payid = " "
		li_rc = wfi_get_payid(ls_payid)

		If li_rc < 0 Then
			dw_cond.object.payid[1] = ""
			dw_cond.object.marknm[1] = ""
			dw_cond.SetColumn("payid")
			Return 0
		End IF

		ls_filter = "payid = '" + data  + "' "
		
	case "paydt"
		dw_cond.object.transdt[1] = dw_cond.object.paydt[1]

End Choose

Return 0
end event

event dw_cond::ue_init();call super::ue_init;DataWindowChild ldwc_trdt
Int    li_rc2, li_exist
String ls_payid

//ls_payid = This.object.payid[1]

If IsNull(ls_payid) Then ls_payid = " "

//li_rc2 = GetChild("trdt", ldwc_trdt)

//IF li_rc2 = -1 THEN 
//	MessageBox(Parent.Title, "Not a DataWindowChild(dw_cond)")
//	Return
//End If

//		ls_filter = "payid = '" + data 
//		ldwc_trdt.SetFilter(ls_filter)			//Filter정함
//ldwc_trdt.SetTransObject(SQLCA)
//li_exist = ldwc_trdt.Retrieve(ls_payid)
////		ldwc_trdt.Filter()
If li_exist < 0 Then 				
//  f_msg_usr_err(2100, Title, "Retrieve()")
//  Return   		//선택 취소 focus는 그곳에
End If  
		
		//선택할수 있게
//		dw_cond.object.trdt.Protect = 0

This.idwo_help_col[1] = This.Object.payid
This.is_help_win[1] = "b5w_hlp_paymst"
This.is_data[1] = "CloseWithReturn"

end event

type p_ok from w_a_reg_m_sql`p_ok within b5w_reg_pre_mtr_inp
integer x = 2565
integer y = 64
end type

type p_close from w_a_reg_m_sql`p_close within b5w_reg_pre_mtr_inp
integer x = 3173
integer y = 64
end type

type gb_cond from w_a_reg_m_sql`gb_cond within b5w_reg_pre_mtr_inp
integer height = 520
end type

type p_save from w_a_reg_m_sql`p_save within b5w_reg_pre_mtr_inp
integer x = 2866
integer y = 64
end type

type dw_detail from w_a_reg_m_sql`dw_detail within b5w_reg_pre_mtr_inp
integer x = 27
integer y = 568
integer width = 3415
integer height = 1376
string dataobject = "b5d_reg_pre_mtr_inp_mst"
boolean ib_sort_use = false
end type

event dw_detail::constructor;call super::constructor;This.SetRowFocusIndicator(FocusRect!)
end event

event dw_detail::retrieveend;call super::retrieveend;//Fromat 
If is_format = "1" Then
	dw_detail.object.payamt.Format = "#,##0.0"
ElseIf is_format = "2" Then
	dw_detail.object.payamt.Format = "#,##0.00"
	
Else
	dw_detail.object.payamt.Format = "#,##0.0"
End If

Return 0 
end event

