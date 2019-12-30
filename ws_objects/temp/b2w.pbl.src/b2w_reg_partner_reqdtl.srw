$PBExportHeader$b2w_reg_partner_reqdtl.srw
$PBExportComments$[chooys]지급거래등록 Window
forward
global type b2w_reg_partner_reqdtl from w_a_reg_m_m
end type
end forward

global type b2w_reg_partner_reqdtl from w_a_reg_m_m
integer width = 2615
end type
global b2w_reg_partner_reqdtl b2w_reg_partner_reqdtl

type variables
String is_partner	//Partner code
String is_commdt	//Commision date
end variables

on b2w_reg_partner_reqdtl.create
call super::create
end on

on b2w_reg_partner_reqdtl.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_partner

String ls_code[], ls_desc
Int	li_cnt

//Condition
ls_partner		= Trim(dw_cond.Object.partner[1])

IF IsNull(ls_partner) THEN ls_partner = ""

//필수항목
IF ls_partner = "" THEN
	f_msg_info(200, Title, "관리대상대리점")
	dw_cond.SetColumn("partner")
	dw_cond.SetFocus()
	Return
END IF

//Dynamic SQL
ls_where = ""

IF ls_partner <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "req.partner = '" + ls_partner + "'"
END IF


//Retrieve
dw_master.is_where = ls_where

//대리점수수료, 대리점미수금, 대리점수수료지급 코드 가져오기
li_cnt = fi_cut_string(fs_get_control("A1","C300",ls_desc),";",ls_code)

//ll_row = dw_master.Retrieve()
ll_rows = dw_master.Retrieve(ls_code[1],ls_code[2],ls_code[3])

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
	Return
ELSEIF ll_rows = 0 THEN
	f_msg_info(1000, Title, "")
	//TriggerEvent("ue_reset")
	p_insert.TriggerEvent("ue_enable")
END IF

end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;dw_detail.Object.new_flag[al_insert_row] 	= "N"

//Log 정보
dw_detail.Object.crt_user[al_insert_row] 	= gs_user_id
dw_detail.Object.crtdt[al_insert_row] 		= fdt_get_dbserver_now()

//대리점(Partner)코드 입력
dw_detail.Object.partner[al_insert_row] = is_partner
dw_detail.Object.commdt[al_insert_row] = DateTime(Date(MidA(is_commdt,1,4)+"-"+MidA(is_commdt,5,2)+"-01"))


//미지급 일련번호 생성
Long ll_preqno

SELECT seq_preqno.nextval
INTO :ll_preqno
FROM dual;

//SELECT max(preqno)+1
//INTO :ll_preqno
//FROM partner_reqdtl;
//
dw_detail.Object.preqno[al_insert_row] = ll_preqno
dw_detail.object.paydt[al_insert_row] = fdt_get_dbserver_now()

RETURN 0
end event

event type integer ue_extra_save();call super::ue_extra_save;Long		ll_rows, ll_rowcnt
String	ls_paydt, ls_commtr, ls_commamt
String	ls_dctype
DEC		ldc_commamt

//필수항목 Check
ll_rows	= dw_detail.RowCount()

FOR ll_rowcnt=1 TO ll_rows
	
	ls_paydt	= String(dw_detail.Object.paydt[ll_rowcnt],"yyyymmdd")
	IF IsNull(ls_paydt) THEN ls_paydt = ""

	IF ls_paydt = "" THEN
		f_msg_usr_err(200, Title, "거래일")
		dw_detail.setColumn("paydt")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	ls_commtr	= Trim(dw_detail.Object.commtr[ll_rowcnt])
	IF IsNull(ls_commtr) THEN ls_commtr = ""

	IF ls_commtr = "" THEN
		f_msg_usr_err(200, Title, "거래유형")
		dw_detail.setColumn("commtr")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF

	
	ls_commamt	= String(dw_detail.Object.commamt[ll_rowcnt])
	IF IsNull(ls_commamt) THEN ls_commamt = ""

	IF ls_commamt = "" THEN
		f_msg_usr_err(200, Title, "수수료")
		dw_detail.setColumn("commamt")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF
	
	ldc_commamt = dw_detail.Object.commamt[ll_rowcnt]
	
	//거래유형의 DC_TYPE이 'C'이고 수수료 지급액>0이면 -처리해준다.
	SELECT dctype
	INTO :ls_dctype
	FROM partner_trcode
	WHERE trcod = :ls_commtr;
	
	IF UPPER(ls_dctype) = 'C' AND ldc_commamt > 0 THEN
		dw_detail.Object.commamt[ll_rowcnt] = -1* ldc_commamt
	END IF

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

type dw_cond from w_a_reg_m_m`dw_cond within b2w_reg_partner_reqdtl
integer x = 59
integer y = 60
integer width = 1577
integer height = 108
string dataobject = "b2dw_cnd_reg_partner_reqdtl"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within b2w_reg_partner_reqdtl
integer x = 1806
integer y = 48
boolean originalsize = false
end type

type p_close from w_a_reg_m_m`p_close within b2w_reg_partner_reqdtl
integer x = 2130
integer y = 48
end type

type gb_cond from w_a_reg_m_m`gb_cond within b2w_reg_partner_reqdtl
integer width = 1646
integer height = 196
end type

type dw_master from w_a_reg_m_m`dw_master within b2w_reg_partner_reqdtl
integer x = 23
integer y = 244
integer width = 2519
string dataobject = "b2dw_inq_partner_reqdtl"
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

ldwo_sort = Object.commdt_t
uf_init(ldwo_sort, "D", RGB(0,0,128))

end event

type dw_detail from w_a_reg_m_m`dw_detail within b2w_reg_partner_reqdtl
integer x = 23
integer y = 688
integer width = 2519
integer height = 948
string dataobject = "b2dw_reg_partner_reqdtl"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;String	ls_where
Long		ll_rows

//Set PartnerCode
is_partner	= Trim(dw_master.Object.partner_reqdtl_partner[al_select_row])
is_commdt	= Trim(dw_master.Object.commdt[al_select_row])

//적용날짜

//Retrieve
If al_select_row > 0 Then
	//PartnerCode
	ls_where = "partner = '" + is_partner + "'"
	ls_where = ls_where + " AND "
	ls_where = ls_where + "to_char(commdt,'yyyymm') = '" + is_commdt + "'"

	
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

type p_insert from w_a_reg_m_m`p_insert within b2w_reg_partner_reqdtl
end type

type p_delete from w_a_reg_m_m`p_delete within b2w_reg_partner_reqdtl
integer y = 1656
end type

type p_save from w_a_reg_m_m`p_save within b2w_reg_partner_reqdtl
integer y = 1656
end type

type p_reset from w_a_reg_m_m`p_reset within b2w_reg_partner_reqdtl
integer y = 1656
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b2w_reg_partner_reqdtl
integer y = 660
end type

