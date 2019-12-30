$PBExportHeader$b2w_reg_partner_ardtl.srw
$PBExportComments$[y.k.min]미수금거래등록 Window
forward
global type b2w_reg_partner_ardtl from w_a_reg_m_m
end type
end forward

global type b2w_reg_partner_ardtl from w_a_reg_m_m
integer width = 3223
integer height = 1968
end type
global b2w_reg_partner_ardtl b2w_reg_partner_ardtl

type variables
String is_orgpartner	//Partner code
String is_partner
String is_commdt
end variables

on b2w_reg_partner_ardtl.create
call super::create
end on

on b2w_reg_partner_ardtl.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_trdtfr, ls_trdtto, ls_org_partner

//Condition
ls_trdtfr		= String(dw_cond.Object.trdt_fr[1], 'yyyymmdd')
ls_trdtto		= String(dw_cond.Object.trdt_to[1], 'yyyymmdd')
ls_org_partner	= Trim(dw_cond.Object.org_partner[1])

IF IsNull(ls_trdtfr) THEN ls_trdtfr = ""
IF IsNull(ls_trdtto) THEN ls_trdtto = ""
IF IsNull(ls_org_partner) THEN ls_org_partner = ""

//Dynamic SQL
ls_where = ""

IF ls_trdtfr = "" THEN
	ls_trdtfr = "00000000"
END IF

IF ls_trdtto = "" THEN
	ls_trdtto = "99999999"
END IF


//IF ls_trdtfr <> "" THEN
//	IF ls_where <> "" THEN ls_where += " AND "
//	ls_where += "to_char(a.trdt, 'yyyymmdd') >= '" + ls_trdtfr + "'"
//END IF
//
//IF ls_trdtto <> "" THEN
//	IF ls_where <> "" THEN ls_where += " AND "
//	ls_where += "to_char(a.trdt, 'yyyymmdd') <= '" + ls_trdtto + "'"
//END IF

IF ls_org_partner <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "b.partner = '" + ls_org_partner + "'"
END IF

//Retrieve
dw_master.is_where = ls_where

//대리점수수료, 대리점미수금, 대리점수수료지급 코드 가져오기
//li_cnt = fi_cut_string(fs_get_control("A1","C300",ls_desc),";",ls_code)

ll_rows = dw_master.Retrieve(ls_trdtfr, ls_trdtto)

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	f_msg_info(1000, Title, "")
END IF

end event

event type integer ue_reset();Constant Int LI_ERROR = -1
Int li_rc

//ii_error_chk = -1

dw_detail.AcceptText()

If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return LI_ERROR//Process Cancel
End If

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_detail.Reset()
dw_master.Reset()
dw_cond.Enabled = True
//dw_cond.Reset()
//dw_cond.InsertRow(0)
//dw_cond.SetFocus()

//ii_error_chk = 0
Return 0

end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//dw_detail.Object.new_flag[al_insert_row] 	= "N"

//Log 정보
dw_detail.Object.crt_user[al_insert_row] 	= gs_user_id
dw_detail.Object.crtdt[al_insert_row] 		= fdt_get_dbserver_now()

//미지급관리대상 총판 가져옴
String ls_uppartner

select partner
into :ls_uppartner
from partnermst
where levelcod = '100'
and	(select prefixno from partnermst where partner = :is_orgpartner) like prefixno || '%';

IF ls_uppartner = "" THEN
	ls_uppartner = "00000000"
END IF

	

//대리점(Partner)코드 입력
dw_detail.Object.partner[al_insert_row] = ls_uppartner
dw_detail.Object.org_partner[al_insert_row] = is_orgpartner

//미지급 일련번호 생성
Long ll_partnerar

SELECT seq_partnerar.nextval
INTO :ll_partnerar
FROM dual;

//SELECT max(preqno)+1
//INTO :ll_preqno
//FROM partner_reqdtl;
//
dw_detail.Object.seq[al_insert_row] = ll_partnerar

RETURN 0
end event

event type integer ue_extra_save();call super::ue_extra_save;Long		ll_rows, ll_rowcnt
String	ls_trdt, ls_artrcod, ls_customerid, ls_tramt
String	ls_dctype

//필수항목 Check
ll_rows	= dw_detail.RowCount()

FOR ll_rowcnt=1 TO ll_rows
	
	ls_trdt	= String(dw_detail.Object.trdt[ll_rowcnt],"yyyymmdd")
	IF IsNull(ls_trdt) THEN ls_trdt = ""

	IF ls_trdt = "" THEN
		f_msg_usr_err(200, Title, "거래일자")
		dw_detail.setColumn("trdt")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	ls_artrcod	= Trim(dw_detail.Object.artrcod[ll_rowcnt])
	IF IsNull(ls_artrcod) THEN ls_artrcod = ""

	IF ls_artrcod = "" THEN
		f_msg_usr_err(200, Title, "거래유형")
		dw_detail.setColumn("artrcod")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF

	
	ls_customerid	= String(dw_detail.Object.customerid[ll_rowcnt])
	IF IsNull(ls_customerid) THEN ls_customerid = ""

	IF ls_customerid = "" THEN
		f_msg_usr_err(200, Title, "고객명")
		dw_detail.setColumn("customerid")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	ls_tramt = String(dw_detail.Object.tramt[ll_rowcnt])
	IF IsNull(ls_tramt) THEN ls_tramt = ""

	IF ls_tramt = "" THEN
		f_msg_usr_err(200, Title, "미수금액")
		dw_detail.setColumn("tramt")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	
	//ldc_commamt = dw_detail.Object.commamt[ll_rowcnt]
	
NEXT

//No Error
RETURN 0
end event

event type integer ue_insert();Constant Int LI_ERROR = -1
Long ll_row
Long	ll_mrows
String ls_partner, ls_commdt
u_cust_a_msg lu_cust_a_msg

ll_mrows = dw_master.rowcount()

//거래내역이 없으면
IF ll_mrows = 0 THEN
 
	//Partner, Commdt 입력
	is_partner = Trim(dw_cond.object.partner[1])
	lu_cust_a_msg = Create u_cust_a_msg
	lu_cust_a_msg.is_data[1] = is_partner
	lu_cust_a_msg.is_data[2] = ""
	OpenWithParm(b2w_reg_partner_reqdtl_popup, lu_cust_a_msg, this)
	
	lu_cust_a_msg = Message.PowerObjectParm
	is_partner = lu_cust_a_msg.is_data[1]
	is_commdt = lu_cust_a_msg.is_data[2]
	
	IF is_partner = "" OR is_commdt = "" THEN
		//TriggerEvent("ue_reset")
		RETURN 0
	END IF
	
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	
END IF

ll_row = dw_detail.InsertRow(dw_detail.rowCount()+1)

dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row) 
dw_detail.SetFocus()
	
If This.Trigger Event ue_extra_insert(ll_row) < 0 Then
	Return 0
End if

return 0
end event

event type integer ue_save();Int li_cnt
String ls_code[], ls_desc


Constant Int LI_ERROR = -1
//Int li_return

//ii_error_chk = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

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
	
	TriggerEvent("ue_ok")
End if

return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b2w_reg_partner_ardtl
integer x = 59
integer y = 44
integer width = 2290
integer height = 184
string dataobject = "b2dw_cnd_reg_partner_ardtl"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within b2w_reg_partner_ardtl
integer x = 2601
integer y = 40
end type

type p_close from w_a_reg_m_m`p_close within b2w_reg_partner_ardtl
integer x = 2601
integer y = 152
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b2w_reg_partner_ardtl
integer height = 252
end type

type dw_master from w_a_reg_m_m`dw_master within b2w_reg_partner_ardtl
integer x = 23
integer y = 268
integer width = 2729
string dataobject = "b2dw_inq_partner_ardtl"
end type

event dw_master::retrieveend;call super::retrieveend;If rowcount >= 0 Then
	p_ok.TriggerEvent("ue_disable")
	
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")   
	p_reset.TriggerEvent("ue_enable")
	
	dw_cond.Enabled = False
End If
end event

event dw_master::ue_init();call super::ue_init;dwObject ldwo_sort

ldwo_sort = Object.org_partner_t
uf_init(ldwo_sort, "D", RGB(0,0,128))


end event

type dw_detail from w_a_reg_m_m`dw_detail within b2w_reg_partner_ardtl
integer x = 23
integer y = 696
integer width = 2734
integer height = 948
string dataobject = "b2dw_reg_partner_ardtl"
end type

event dw_detail::constructor;call super::constructor;//SetRowFocusIndicator(off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;String	ls_where, ls_trdtfr, ls_trdtto
Long		ll_rows

//Set PartnerCode
ls_trdtfr	= String(dw_cond.Object.trdt_fr[1], 'yyyymmdd')
ls_trdtto	= String(dw_cond.Object.trdt_to[1], 'yyyymmdd')
is_orgpartner	= Trim(dw_master.Object.org_partner[al_select_row])

//적용날짜

//Retrieve
If al_select_row > 0 Then
	ls_where = "a.org_partner = '" + is_orgpartner + "'"
	
	IF ls_trdtfr <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "to_char(trdt, 'yyyymmdd') >= '" + ls_trdtfr + "'"
	END IF
	
	IF ls_trdtto <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "to_char(trdt, 'yyyymmdd') <= '" + ls_trdtto + "'"
	END IF
		
	dw_detail.is_where = ls_where		
	
	ll_rows = dw_detail.Retrieve()

	If ll_rows < 0 Then
		f_msg_usr_err(2100, Parent.Title, "Retrieve()")
		Return -1
	ElseIf ll_rows = 0 Then
		//Return 1
	End If
End if

Return 0
end event

event dw_detail::ue_init();call super::ue_init;//Help Window
This.idwo_help_col[1] = This.Object.customerid
This.is_help_win[1] = "b1w_hlp_customerm"
This.is_data[1] = "CloseWithReturn"
end event

event dw_detail::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If dw_detail.iu_cust_help.ib_data[1] Then
			 dw_detail.Object.customerid[row] = &
			 dw_detail.iu_cust_help.is_data[1]
		End If
End Choose

Return 0 
end event

type p_insert from w_a_reg_m_m`p_insert within b2w_reg_partner_ardtl
end type

type p_delete from w_a_reg_m_m`p_delete within b2w_reg_partner_ardtl
end type

type p_save from w_a_reg_m_m`p_save within b2w_reg_partner_ardtl
end type

type p_reset from w_a_reg_m_m`p_reset within b2w_reg_partner_ardtl
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b2w_reg_partner_ardtl
integer y = 668
end type

