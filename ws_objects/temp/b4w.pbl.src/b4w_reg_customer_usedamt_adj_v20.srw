$PBExportHeader$b4w_reg_customer_usedamt_adj_v20.srw
$PBExportComments$[ohj] 고객별 한도잔액 증감처리 v20
forward
global type b4w_reg_customer_usedamt_adj_v20 from w_a_reg_m_m
end type
end forward

global type b4w_reg_customer_usedamt_adj_v20 from w_a_reg_m_m
integer width = 3191
integer height = 1964
boolean clientedge = true
end type
global b4w_reg_customer_usedamt_adj_v20 b4w_reg_customer_usedamt_adj_v20

type variables
String is_partner, is_partner_1, is_limit_flag
end variables

on b4w_reg_customer_usedamt_adj_v20.create
call super::create
end on

on b4w_reg_customer_usedamt_adj_v20.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String	ls_where
Long		ll_rows
String	ls_payid, ls_svccod

ls_payid	 = Trim(dw_cond.Object.payid[1])
ls_svccod = Trim(dw_cond.Object.svccod[1])

IF( IsNull(ls_payid) ) THEN ls_payid = ""
If ls_payid = "" Then
	f_msg_usr_err(200, Title, "납입자번호")
	dw_cond.SetFocus()
	dw_cond.SetColumn("payid")
	Return
End If

If ls_svccod = "" Then
	f_msg_usr_err(200, Title, "서비스")
	dw_cond.SetFocus()
	dw_cond.SetColumn("svccod")
	Return 
End If

//Dynamic SQL
IF ls_payid <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "d.payid = '" + ls_payid + "' AND d.svccod = '"	+ls_svccod +"' "
END IF

//IF ls_where <> "" THEN ls_where += " AND "
//ls_where += "limit_flag = '" + is_limit_flag + "' "
//
dw_master.is_where	= ls_where
ll_rows = dw_master.Retrieve()

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	f_msg_info(1000, Title, "")

	dw_cond.Object.adj_type.protect = 1
	dw_cond.Object.adj_amt.protect = 1
	dw_cond.Object.note.protect = 1
	dw_master.reset()
	dw_detail.reset()
	p_ok.TriggerEvent("ue_enable")
	return	
ELSE
	dw_cond.Object.adj_type[1] = ''
	dw_cond.Object.adj_amt[1] = 0
	dw_cond.Object.note[1] = ''

	dw_cond.Object.adj_type.protect = 0
	dw_cond.Object.adj_amt.protect = 0
	dw_cond.Object.note.protect = 0
End If

p_save.TriggerEvent("ue_enable")

end event

event type integer ue_extra_save();call super::ue_extra_save;String ls_where
Long ll_row, ll_limitbal_qty, ll_cnt, ll_cnt_1, ll_cnt_2, ll_cnt_3
String ls_payid, ls_svccod, ls_adj_type, ls_note
Integer li_return, li_ret, li_rc
Dec{2} lc_adj_amt, lc_deposit_amt, lc_limit_amt

dw_cond.AcceptText()

ls_payid    = fs_snvl(dw_cond.Object.payid[1], '')
ls_svccod   = fs_snvl(dw_cond.Object.svccod[1], '')
ls_adj_type = fs_snvl(dw_cond.Object.adj_type[1], '')
ls_note     = fs_snvl(dw_cond.Object.note[1], '')
lc_deposit_amt = dw_master.object.deposit_amt[dw_master.getrow()]
lc_limit_amt   = dw_master.object.limit_amt[dw_master.getrow()]
lc_adj_amt     = dw_cond.Object.adj_amt[1]

If IsNull(lc_adj_amt) Then lc_adj_amt = 0

If ls_payid = "" Then
	f_msg_usr_err(200, Title, "납부자번호")
	dw_cond.SetFocus()
	dw_cond.SetColumn("payid")
	Return -2
End If

If ls_svccod = "" Then
	f_msg_usr_err(200, Title, "서비스")
	dw_cond.SetFocus()
	dw_cond.SetColumn("svccod")
	Return -2
End If

If ls_adj_type = "" Then
	f_msg_usr_err(200, Title, "증감구분")
	dw_cond.SetFocus()
	dw_cond.SetColumn("adj_type")
	Return -2
End If

If ls_adj_type <> "C" Then
	If lc_adj_amt <= 0 Then
		f_msg_usr_err(201, Title, "할당량은 0보다 커야 합니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("adj_amt")
		Return -2
	End If
	
	If  ls_adj_type = "M" Then
		If lc_limit_amt < lc_adj_amt Then
			f_msg_usr_err(201, Title, "한도잔액보다 감액금액이 클 수 없습니다.")
			dw_cond.SetFocus()
			dw_cond.SetColumn("adj_amt")
			Return -2
		End If
	Else		
		If lc_deposit_amt < lc_limit_amt + lc_adj_amt Then
			f_msg_usr_err(201, Title, "보증금총액보다 한도잔액이 클 수 없습니다.")
			dw_cond.SetFocus()
			dw_cond.SetColumn("adj_amt")
			Return -2
		End If
	End If
Else
	If lc_deposit_amt = lc_limit_amt Then
		f_msg_usr_err(201, Title, "보증금총액과 한도잔액이 같습니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("adj_amt")
		Return -2
	End If
End If
	
//***** 처리부분 *****
b4u_dbmgr_v20 iu_db

iu_db = Create b4u_dbmgr_v20
iu_db.is_title = Title
iu_db.is_caller = "b4w_reg_customer_usedamt_adj_v20%save"
iu_db.is_data[1] = ls_payid      //대리점
iu_db.is_data[2] = ls_svccod		//가격정책
iu_db.is_data[3] = ls_adj_type		//유형
iu_db.is_data[4] = ls_note	   	//비고
iu_db.is_data[5] = gs_user_id
iu_db.is_data[6] = gs_pgm_id[gi_open_win_no]
iu_db.ic_data[1] = lc_adj_amt		   //할당금액
iu_db.ic_data[2] = lc_deposit_amt   //보증금총액
iu_db.ic_data[3] = lc_limit_amt  	//한도잔액

//iu_db.idw_data[1] = dw_detail

iu_db.uf_prc_db_01()
li_rc	= iu_db.ii_rc

Destroy iu_db
Return li_rc

end event

event open;call super::open;String ls_ref_desc


//dw_cond.object.svccod.Protect = 1
dw_cond.object.adj_type.Protect = 1
dw_cond.object.adj_amt.Protect = 1
dw_cond.object.note.Protect = 1

dw_detail.SetRowFocusIndicator(Off!)
end event

event resize;call super::resize;
SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	
		p_save.Y    = p_ok.Y
	
Else

		p_save.Y    = p_ok.Y
End If


SetRedraw(True)
end event

event type integer ue_save();Integer li_return
String ls_partner, ls_where
Dec{2} lc_tot_credit, lc_tot_samt, lc_tot_balance

If dw_cond.AcceptText() < 1 Then//???
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_cond.SetFocus()
	Return -1
End If


li_return = This.Trigger Event ue_extra_save()

Choose Case li_return
	Case Is < -2
		dw_cond.SetFocus()
	Case -2
		dw_cond.SetFocus()
	Case -1
		
		//ROLLBACK
		iu_cust_db_app.is_title = This.Title
		iu_cust_db_app.is_caller = "ROLLBACK"
		iu_cust_db_app.uf_prc_db()
		If iu_cust_db_app.ii_rc = -1 Then Return -1
		f_msg_info(3010, This.Title, "고객 한도잔액 증감처리")
	Case Is >= 0
		//COMMIT
		iu_cust_db_app.is_title = This.Title
		iu_cust_db_app.is_caller = "COMMIT"
		iu_cust_db_app.uf_prc_db()
		If iu_cust_db_app.ii_rc = -1 Then Return -1
		f_msg_info(3000, This.Title, "고객 한도잔액 증감처리완료")
		//If ib_reset_saveafter Then
			//p_save.TriggerEvent("ue_disable")
			//dw_detail.Reset()
			Trigger event ue_ok()
			//dw_master.Retrieve()
			//dw_detail.Retrieve()
		//end if
End Choose

return 0


end event

type dw_cond from w_a_reg_m_m`dw_cond within b4w_reg_customer_usedamt_adj_v20
event dropdownlist pbm_dwndropdown
integer y = 40
integer width = 1765
integer height = 668
string dataobject = "b4dw_cnd_reg_customer_usedamt_adj_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;String ls_col, ls_payid, ls_customernm, ls_adj_type

//ls_col = dw_cond.GetColumnName()

//dw_cond.Object.priceplan.protect = 1
//


Choose Case dwo.name
	case "payid"
		ls_payid = Trim(dw_cond.Object.payid[1])
		SELECT customernm
		  INTO :ls_customernm
		  FROM customerm
		  WHERE customerid = :ls_payid;
		  
		If SQLCA.SQLCode = 100 Then		//Not Found
			f_msg_usr_err(201, Title, "고객번호")
			dw_cond.SetFocus()
			dw_cond.SetColumn("payid")
			Return -1
		End If		
		dw_cond.Object.customernm[1] = ls_customernm
		
		dw_cond.Object.adj_type[1] = ''
		dw_cond.Object.adj_amt[1] = 0
		dw_cond.Object.note[1] = ''

		dw_cond.Object.adj_type.protect = 0
		dw_cond.Object.adj_amt.protect = 0
		dw_cond.Object.note.protect = 0
		dw_master.reset()
		dw_detail.reset()
		p_ok.TriggerEvent("ue_enable")

	Case "svccod"
		
		ls_payid = Trim(dw_cond.Object.payid[1])
		IF( IsNull(ls_payid) ) THEN ls_payid = ""
		
		If ls_payid = "" Then
			f_msg_usr_err(200, Title, "고객을 먼저 선택 하십시오")
			dw_cond.Object.svccod[1] = ""
			dw_cond.SetFocus()
			dw_cond.SetColumn("payid")  
			Return -1
		End If		
		
	Case "adj_type"
		
		ls_adj_type = Trim(dw_cond.Object.adj_type[1])
		
		If ls_adj_type = "C" Then
			dw_cond.Object.adj_amt[1] = 0
			dw_cond.Object.adj_amt.protect = 1
		Else
			dw_cond.Object.adj_amt[1] = 0
			dw_cond.Object.adj_amt.protect = 0
		End If
			
End Choose

Return 0


end event

event dw_cond::ue_init();call super::ue_init;idwo_help_col[1] = Object.payid
is_help_win[1] = "b4w_hlp_customer_deposit_v20"
is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
			Object.payid[row]      = iu_cust_help.is_data[1]
			Object.customernm[row] = iu_cust_help.is_data[2]			
			Object.svccod[row]     = iu_cust_help.is_data[4]	
		End If
		
		//dw_cond.Object.svccod[1] = ''
		dw_cond.Object.adj_type[1] = ''
		dw_cond.Object.adj_amt[1] = 0
		dw_cond.Object.note[1] = ''
		dw_cond.Object.svccod.protect = 0
		dw_cond.Object.adj_type.protect = 0
		dw_cond.Object.adj_amt.protect = 0
		dw_cond.Object.note.protect = 0
		dw_master.reset()
		dw_detail.reset()
		p_ok.TriggerEvent("ue_enable")
		
End Choose
end event

type p_ok from w_a_reg_m_m`p_ok within b4w_reg_customer_usedamt_adj_v20
integer x = 2011
integer y = 52
end type

type p_close from w_a_reg_m_m`p_close within b4w_reg_customer_usedamt_adj_v20
integer x = 2629
integer y = 52
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b4w_reg_customer_usedamt_adj_v20
integer width = 1883
integer height = 724
integer taborder = 20
end type

type dw_master from w_a_reg_m_m`dw_master within b4w_reg_customer_usedamt_adj_v20
integer x = 9
integer y = 748
integer width = 3109
integer height = 492
integer taborder = 30
string dataobject = "b4dw_reg_mst_customer_usedamt_adj_v20"
end type

event dw_master::ue_init();call super::ue_init;dwObject ldwo_sort
ldwo_sort = Object.payid_t
uf_init(ldwo_sort)
end event

event dw_master::retrieveend;call super::retrieveend;dw_cond.Enabled = True
end event

type dw_detail from w_a_reg_m_m`dw_detail within b4w_reg_customer_usedamt_adj_v20
integer x = 9
integer y = 1284
integer width = 3109
integer height = 532
integer taborder = 40
string dataobject = "b4dw_reg_det_customer_usedamt_adj_v20"
end type

event dw_detail::constructor;call super::constructor;//dw_detail.SetRowFocusIndicator(Off!)

end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;String ls_payid,ls_svccod
String ls_where
Long ll_row

ls_payid = Trim(dw_master.Object.payid[al_select_row])
ls_svccod = Trim(dw_master.Object.svccod[al_select_row])


If al_select_row > 0 Then
	ls_where = "payid = '" + ls_payid + "' AND svccod = '" + ls_svccod +"' "
	dw_detail.is_where = ls_where		
	ll_row = dw_detail.Retrieve()	
	If ll_row < 0 Then
		f_msg_usr_err(2100, Parent.Title, "Retrieve()")
		Return -1
	End If
End if

Return 0
end event

event dw_detail::rowfocuschanged;call super::rowfocuschanged;If currentrow <= 0 Then return 0

SelectRow(0 , FALSE)
SelectRow(currentrow ,TRUE )

end event

type p_insert from w_a_reg_m_m`p_insert within b4w_reg_customer_usedamt_adj_v20
boolean visible = false
integer x = 23
integer y = 1708
end type

type p_delete from w_a_reg_m_m`p_delete within b4w_reg_customer_usedamt_adj_v20
boolean visible = false
integer x = 315
integer y = 1708
end type

type p_save from w_a_reg_m_m`p_save within b4w_reg_customer_usedamt_adj_v20
integer x = 2322
integer y = 52
boolean enabled = true
end type

type p_reset from w_a_reg_m_m`p_reset within b4w_reg_customer_usedamt_adj_v20
boolean visible = false
integer x = 1339
integer y = 1708
boolean enabled = true
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b4w_reg_customer_usedamt_adj_v20
integer x = 9
integer y = 1244
end type

