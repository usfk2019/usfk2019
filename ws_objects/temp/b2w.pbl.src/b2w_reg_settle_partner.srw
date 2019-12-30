$PBExportHeader$b2w_reg_settle_partner.srw
$PBExportComments$[parkkh] 정산사업자등록
forward
global type b2w_reg_settle_partner from w_a_reg_m_m
end type
end forward

global type b2w_reg_settle_partner from w_a_reg_m_m
integer width = 3333
integer height = 2208
end type
global b2w_reg_settle_partner b2w_reg_settle_partner

type variables
String  is_priceplan

end variables

on b2w_reg_settle_partner.create
call super::create
end on

on b2w_reg_settle_partner.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b2w_reg_settle_partner
	Desc.	: 	정산사업자등록
	Ver.	:	1.0
	Date	: 	2002.10.23
	Programer : Park Kyung Hae(parkkh)
--------------------------------------------------------------------------*/

end event

event ue_ok();call super::ue_ok;//Service 별 요금 조회
String ls_partner, ls_where, ls_partnernm, ls_cregno
Long ll_row

dw_cond.AcceptText()
ls_partner = Trim(dw_cond.object.partner[1])
ls_partnernm = Trim(dw_cond.object.partnernm[1])
ls_cregno = Trim(dw_cond.object.cregno[1])

//Null Check
If IsNull(ls_partner) Then ls_partner = ""
If IsNull(ls_partnernm) Then ls_partnernm = ""
If IsNull(ls_cregno) Then ls_cregno = ""

//Retrieve
ls_where = ""
IF ls_partner <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "partner like '" + ls_partner + "%' "
End If

IF ls_partnernm <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "Upper(partnernm) like '" + Upper(ls_partnernm) + "%' "
End If

IF ls_cregno <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cregno = '" + ls_cregno + "' "
End If

dw_master.SetRedraw(false)
dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
   Return
End If
dw_master.SetRedraw(true)
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Insert시 조건
Long ll_master_row, ll_seq , i, ll_row

//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("partner")

//Log
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()


//Display
//dw_detail.object.partner.Protect = 0
//dw_detail.object.partner.Pointer = "help.cur"
//dw_detail.idwo_help_col[1] = dw_detail.object.partner
	
Return 0 
end event

event type integer ue_extra_save();//Save Check
String ls_partner, ls_partnernm, ls_levelcod, ls_hpartner, ls_logid, ls_password, ls_emp_id
Long ll_row, ll_cnt, ll_rows

//Row 수가 없으면
ll_rows = dw_detail.RowCount()
If ll_rows = 0 Then Return 0

ll_row = dw_detail.getrow()

//Update Log
dw_detail.object.updt_user[ll_row] = gs_user_id
dw_detail.object.updtdt[ll_row] = fdt_get_dbserver_now()

dw_detail.AcceptText()
//필수 Check
ls_partner = Trim(dw_detail.object.partner[ll_row])
ls_partnernm = Trim(dw_detail.object.partnernm[ll_row])
ls_logid = Trim(dw_detail.object.logid[ll_row])
ls_password = Trim(dw_detail.object.logpwd[ll_row])
ls_emp_id = Trim(dw_detail.object.emp_id[ll_row])

If IsNull(ls_partner) Then ls_partner = ""
If IsNull(ls_partnernm) Then ls_partnernm = ""
If IsNull(ls_password) Then ls_password = ""
If IsNull(ls_logid) Then ls_logid = ""
If IsNull(ls_emp_id) Then ls_emp_id = ""

//If ls_partner = "" Then
//	f_msg_usr_err(200, title, "대리점코드")
//	dw_detail.SetFocus()
//	dw_detail.SetColumn("partner")
//	return -2
//End If

If ls_partnernm = "" Then
	f_msg_usr_err(200, title, "대리점명")
	dw_detail.SetFocus()
	dw_detail.SetColumn("partnernm")
	Return -2
End If

If ls_logid= "" Then
	f_msg_usr_err(200, title, "Web Login ID")
	dw_detail.SetFocus()
	dw_detail.SetColumn("logid")
	Return -2
End If

If ls_password = "" Then
	f_msg_usr_err(200, title, "Password")
	dw_detail.SetFocus()
	dw_detail.SetColumn("logpwd")
	Return -2
End If

If ls_emp_id = "" Then
	f_msg_usr_err(200, title, "System User ID")
	dw_detail.SetFocus()
	dw_detail.SetColumn("emp_id")
	Return -2
End If

dw_detail.object.hpartner[ll_row] = ls_partner

If dw_detail.GetItemStatus(ll_row, 0, Primary!) = NewModified! THEN

//   ll_cnt = 0
//	select count(*)
//	  into :ll_cnt
//	  from partnermst
//	 where partner = :ls_partner;
//	  
//	If SQLCA.SQLCode < 0 Then
//		f_msg_sql_err(This.Title, "대리점 코드 check")
//		RollBack;
//		Return -1
//	End If				
//	
//	If ll_cnt <> 0 Then
//		f_msg_usr_err(9000, Title, "이미 사용중인 대리점코드입니다. 다시 입력하세요!!")  //삭제 안됨 
//		dw_detail.SetFocus()
//		dw_detail.SetColumn("partner")
//		return -2
//	End If

	//partner seq 가져 오기
	Select 'S'|| to_char(seq_partnerno.nextval)
	Into :ls_partner
	From dual;
	
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, "SELECT seq_partnerno.nextval")			
		Return -1
	End If	
	
	dw_detail.object.partner[ll_row] = ls_partner

	ll_cnt = 0
	select count(*)
	  into :ll_cnt
	  from partnermst
	 where logid = :ls_logid;
	  
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(This.Title, "logid check")
		RollBack;
		Return -1
	End If				
	
	If ll_cnt <> 0 Then
		f_msg_usr_err(9000, Title, "이미 사용중인 logid입니다. 다시 입력하세요!!")  //삭제 안됨 
		dw_detail.SetFocus()
		dw_detail.SetColumn("logid")
		Return -2
	End If
	
elseIF dw_detail.GetItemStatus(ll_row, "logid", Primary!) = DataModified! Then

	ll_cnt = 0
	select count(*)
	  into :ll_cnt
	  from partnermst
	 where logid = :ls_logid
		and partner <> :ls_partner;
	  
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(This.Title, "logid check")
		RollBack;
		Return -1
	End If				
	
	If ll_cnt <> 0 Then
		f_msg_usr_err(9000, Title, "이미 사용중인 logid입니다. 다시 입력하세요!!")  //삭제 안됨 
		dw_detail.SetFocus()
		dw_detail.SetColumn("logid")
		Return -2
	End If
	
End If

Return 0
end event

event type integer ue_extra_delete();call super::ue_extra_delete;//Delete 조건
Dec lc_troubleno
Long ll_master_row, ll_cnt
String ls_partner

ll_master_row = dw_master.GetRow()
If ll_master_row = 0 Then  Return 0    //삭제 가능

ls_partner = dw_detail.object.partner[dw_detail.getrow()]

//삭제하고자하는 파트너코드가 svcorder(서비스신청내역) table에 존재할때 삭제불가
Select count(*)
  into :ll_cnt
  from svcorder
 where reg_partner = :ls_partner
	 or maintain_partner = :ls_partner
	 or sale_partner = :ls_partner
	 or settle_partner = :ls_partner
	 or partner = :ls_partner;
	 
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(This.Title, "Select Error")
	RollBack;
	Return -1
End If				

If ll_cnt <> 0 Then
	f_msg_usr_err(9000, Title, "삭제불가! 서비스신청내역에 해당파트너가 존재합니다.")  //삭제 안됨 
	Return -1
End If

//삭제하고자하는 파트너코드가 contractmst(계약마스터) table에 존재할때 삭제불가		
Select count(*)
  into :ll_cnt
  from contractmst
 where reg_partner = :ls_partner
	 or maintain_partner = :ls_partner
	 or sale_partner = :ls_partner
	 or settle_partner = :ls_partner
	 or partner = :ls_partner;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(This.Title, "Select Error")
	RollBack;
	Return -1
End If				

If ll_cnt <> 0 Then
	f_msg_usr_err(9000, Title, "삭제불가! 계약마스터에 해당파트너가 존재합니다.")  //삭제 안됨 
	Return -1
End If

Return 0 
end event

event type integer ue_save();int li_return
Constant Int LI_ERROR = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

li_return = This.Trigger Event ue_extra_save()
Choose Case li_return
	Case -2
		//필수항목 미입력
		dw_detail.SetFocus()
		Return -2
	Case -1
		dw_detail.SetFocus()
		Return LI_ERROR
End Choose	

If dw_detail.Update() < 0 then
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
	f_msg_info(3000,This.Title,"Save")
End if

//재정의
String ls_partner, ls_partnernm, ls_cregno

ls_partnernm = Trim(dw_cond.object.partnernm[1])
ls_cregno = dw_cond.object.cregno[1]
ls_partner = Trim(dw_cond.object.partner[1])

//Reset
Trigger Event ue_reset()
dw_cond.object.partnernm[1] = ls_partnernm
dw_cond.object.cregno[1] = ls_cregno
dw_cond.object.partner[1] = ls_partner
Trigger Event ue_ok()

return 0 
end event

event type integer ue_insert();//insert시 reset하고 한행만 insert 조상스트립트 수정!!
Long ll_row

dw_detail.Setredraw(False)
dw_detail.reset()
ll_row = dw_detail.InsertRow(0)
dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row)
dw_detail.SetFocus()

If This.Trigger Event ue_extra_insert(ll_row) < 0 Then
	Return 0
End if

dw_detail.Setredraw(True)


Return 0
//ii_error_chk = 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b2w_reg_settle_partner
integer x = 32
integer y = 40
integer width = 2496
integer height = 244
string dataobject = "b2dw_cnd_reg_settle_partner"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within b2w_reg_settle_partner
integer x = 2651
integer y = 64
end type

type p_close from w_a_reg_m_m`p_close within b2w_reg_settle_partner
integer x = 2971
integer y = 64
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b2w_reg_settle_partner
integer x = 23
integer width = 2546
end type

type dw_master from w_a_reg_m_m`dw_master within b2w_reg_settle_partner
integer x = 23
integer width = 3246
integer height = 556
string dataobject = "b2dw_inq_settle_partner"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.partner_t
uf_init(ldwo_sort)
end event

event dw_master::retrieveend;call super::retrieveend;//처음 입력 했을시
If rowcount = 0 Then
	p_ok.TriggerEvent("ue_disable")
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_cond.Enabled = False
End If



end event

type dw_detail from w_a_reg_m_m`dw_detail within b2w_reg_settle_partner
integer y = 924
integer width = 3246
integer height = 984
string dataobject = "b2dw_reg_settle_partner"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//dw_master cleck시 Retrieve
String ls_where, ls_partner
Long ll_row, i
Integer li_cnt

ls_partner = Trim(dw_master.object.partner[al_select_row])
If IsNull(ls_partner) Then ls_partner = ""
ls_where = ""

If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "partner = '" + ls_partner + "' "
End If

//dw_detail 조회
dw_detail.SetRedraw(False)
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -2
End If

////partner 값 수정 못한다...
//dw_detail.object.partner.Protect = 1
//dw_detail.object.partner.Pointer = "Arrow!"
//dw_detail.idwo_help_col[1] = dw_detail.object.updt_user

dw_detail.SetRedraw(True)

Return 0
end event

event dw_detail::ue_init();call super::ue_init;//help Window
//this.is_help_win[3] = "b2w_hlp_partnermst"
//this.idwo_help_col[3] = this.Object.partner
//this.is_data[3] = "CloseWithReturn"

this.is_help_win[1] = "b2w_hlp_logid"
this.idwo_help_col[1] = this.Object.logid
this.is_data[1] = "CloseWithReturn"

this.is_help_win[2] = "w_hlp_post"
this.idwo_help_col[2] = this.Object.zipcod
this.is_data[2] = "CloseWithReturn"
end event

event dw_detail::doubleclicked;call super::doubleclicked;Choose Case dwo.name
//	Case "partner"		//partner
//		If This.GetItemStatus(row, 0, Primary!) = NewModified! THEN		
//			If this.iu_cust_help.ib_data[1] Then
//				 this.Object.partner[row] = this.iu_cust_help.is_data[1]
//				 this.Object.logid[row] = this.iu_cust_help.is_data[1]
//			End If
//		End if
	Case "logid"		//Log ID
		If this.iu_cust_help.ib_data[1] Then
			 this.Object.logid[row] = this.iu_cust_help.is_data[1]
		End If
	Case "zipcod"
		If this.iu_cust_help.ib_data[1] Then
			this.Object.zipcod[row] = this.iu_cust_help.is_data[1]
			this.Object.addr1[row] = this.iu_cust_help.is_data[2]
			this.Object.addr2[row] = this.iu_cust_help.is_data[3]
		End If
End Choose

Return 0 
end event

event dw_detail::itemchanged;call super::itemchanged;//Choose Case dwo.name
//	Case "partner"
//		 This.Object.logid[row] = data
//End Choose
end event

type p_insert from w_a_reg_m_m`p_insert within b2w_reg_settle_partner
integer x = 41
integer y = 1936
end type

type p_delete from w_a_reg_m_m`p_delete within b2w_reg_settle_partner
integer x = 366
integer y = 1936
end type

type p_save from w_a_reg_m_m`p_save within b2w_reg_settle_partner
integer x = 695
integer y = 1936
end type

type p_reset from w_a_reg_m_m`p_reset within b2w_reg_settle_partner
integer x = 1344
integer y = 1936
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b2w_reg_settle_partner
integer y = 884
end type

