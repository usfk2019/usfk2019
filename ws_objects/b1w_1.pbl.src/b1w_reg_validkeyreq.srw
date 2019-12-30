$PBExportHeader$b1w_reg_validkeyreq.srw
$PBExportComments$[ssong]인증KEY요청내역조회/수정
forward
global type b1w_reg_validkeyreq from w_a_reg_m_m
end type
end forward

global type b1w_reg_validkeyreq from w_a_reg_m_m
integer width = 4402
integer height = 2124
end type
global b1w_reg_validkeyreq b1w_reg_validkeyreq

type variables
String is_receiptcod
end variables

forward prototypes
public function integer wfi_get_customerid (string as_customerid)
public function integer wfi_get_partner (string as_partner)
end prototypes

public function integer wfi_get_customerid (string as_customerid);/*------------------------------------------------------------------------
	Name	: wfi_get_customerid
	Desc	: 고객 Id 구하기]
	Date	: 2002.10.01
	Arg.	: string as_customerid
	Retrun	: integer
	 			-1 : Error
	Ver.	: 1.0
	programer : Choi Bo Ra (ceusee)
------------------------------------------------------------------------*/
String ls_customernm
Select customernm
Into :ls_customernm
From customerm
Where customerid = :as_customerid;

If SQLCA.SQLCode = 100 Then		//Not Found
   f_msg_usr_err(201, Title, "고객번호")
   dw_cond.SetFocus()
   dw_cond.SetColumn("customerid")
   Return -1
End If

dw_cond.object.customernm[1] = ls_customernm
Return 0

end function

public function integer wfi_get_partner (string as_partner);String ls_partnernm

Select partnernm
Into :ls_partnernm
From partnermst
Where partner = :as_partner
  and partner_type= '0';

If SQLCA.SQLCODE = 100 Then
	Return -1
End If

Return 0
end function

on b1w_reg_validkeyreq.create
call super::create
end on

on b1w_reg_validkeyreq.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_validkey_req
	Desc.	: 	인증KEY요청내역조회및수정
	Ver.	:	1.0
	Date	: 	2004.07.22
	Programer : Song Eun Mi
--------------------------------------------------------------------------*/

String ls_ref_desc, ls_temp, ls_name[]

//인증key요청처리상태(1.요청(00);2.처리완료(11);3.처리실패(임의)(22);4.처리불가(33))
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("B1", "P501", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", ls_name[])
is_receiptcod = ls_name[2]
end event

event ue_ok();call super::ue_ok;//해당 요청일의 인증key 조회
String ls_reqdt_from, ls_reqdt_to, ls_reqtype, ls_validkey, ls_status, ls_req_partner, ls_where
Long ll_row

ls_reqdt_from = String(dw_cond.object.reqdt_from[1],'yyyymmdd')
ls_reqdt_to = String(dw_cond.object.reqdt_to[1],'yyyymmdd')
ls_reqtype = Trim(dw_cond.object.reqtype[1])
ls_validkey = Trim(dw_cond.object.validkey[1])
ls_status = Trim(dw_cond.object.status[1])
ls_req_partner = Trim(dw_cond.object.req_partner[1])

If IsNull(ls_reqdt_from) Then ls_reqdt_from = ""
If IsNull(ls_reqdt_to) Then ls_reqdt_to = ""
If IsNull(ls_reqtype) Then ls_reqtype = ""
If IsNull(ls_validkey) Then ls_validkey = ""
If IsNull(ls_status) Then ls_status = ""
If IsNull(ls_req_partner) Then ls_req_partner = ""


If ls_reqdt_from <> "" And ls_reqdt_to <> "" Then
	If ls_reqdt_from > ls_reqdt_to Then
		f_msg_usr_err(201, Title, "Activation Date")
		dw_cond.SetFocus()
		dw_cond.SetColumn("reqdt_from")
	   Return
	End If
End If


If ls_reqdt_from <> "" Then
  If ls_where <> "" Then ls_where += " And "  
  ls_where += "to_char(reqdt,'YYYYMMDD') >='" + ls_reqdt_from + "' " 
End if

If ls_reqdt_to <> "" Then
  If ls_where <> "" Then ls_where += " And "  
  ls_where += "to_char(reqdt,'YYYYMMDD') <='" + ls_reqdt_to + "' " 
End if

IF ls_reqtype <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += " reqtype = '" + ls_reqtype + "' "
End If

IF ls_validkey <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += " validkey = '" + ls_validkey + "' "
End If

IF ls_status <> "" Then
	If ls_where <> "" Then ls_where += "And "
		ls_where += " status = '" + ls_status + "' "
End If

IF ls_req_partner <> "" Then
	If ls_where <> "" Then ls_where += "And "
		ls_where += " req_partner = '" + ls_req_partner + "'"
End If
	


dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title , "")
	return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
   Return
End If

end event

event type integer ue_extra_save();call super::ue_extra_save;//Save Check
String ls_status
Long   ll_rows, ll_rowcnt, i

dw_detail.AcceptText()
ll_rows = dw_detail.RowCount()
If ll_rows = 0 Then Return 0

ls_status = Trim(dw_detail.object.status[1])

//Null Check
If IsNull(ls_status) Then ls_status = ""

If ls_status = "" Then
   f_msg_usr_err(200, Title, "처리상태")
   dw_detail.SetFocus()
   dw_detail.SetColumn("status")
   Return -2
End If

//처리완료 상태에서는 다른상태로 처리불가



If dw_detail.GetItemStatus(ll_rowcnt, 0, Primary!) = DataModified! THEN
	dw_detail.object.contractmst_updt_user[ll_rowcnt] = gs_user_id
	dw_detail.object.contractmst_updtdt[ll_rowcnt] = fdt_get_dbserver_now()
End If
	
Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Insert log

dw_detail.Object.priceplan_validkey_type_crt_user[al_insert_row]	= gs_user_id
dw_detail.Object.priceplan_validkey_type_crtdt[al_insert_row]		= fdt_get_dbserver_now()
dw_detail.Object.priceplan_validkey_type_updt_user[al_insert_row]	= gs_user_id
dw_detail.Object.priceplan_validkey_type_updtdt[al_insert_row]		= fdt_get_dbserver_now()
dw_detail.Object.priceplan_validkey_type_pgm_id[al_insert_row]		= gs_pgm_id[gi_open_win_no]

RETURN 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_validkeyreq
integer x = 59
integer y = 76
integer width = 3287
integer height = 212
string dataobject = "b1dw_reg_cnd_validkeyreq"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_validkeyreq
integer x = 3511
integer y = 60
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_validkeyreq
integer x = 3813
integer y = 60
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_validkeyreq
integer width = 3342
integer height = 320
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_validkeyreq
integer x = 23
integer y = 356
integer width = 4293
integer height = 792
string dataobject = "b1dw_reg_master_validkeyreq"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.vreqno_t
uf_init(ldwo_sort)
end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_validkeyreq
integer x = 14
integer y = 1188
integer width = 4288
integer height = 660
string dataobject = "b1dw_reg_det_validkeyreq"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//dw_master cleck시 Retrieve
String ls_where, ls_vreqno, ls_status
Long ll_row
Dec ldc_vreqno

ldc_vreqno = dw_master.object.vreqno[al_select_row]
ls_vreqno = string(ldc_vreqno)
If IsNull(ldc_vreqno) Then ls_vreqno = ""
ls_where = ""
If ls_vreqno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "vreqno = " + ls_vreqno + ""
End If

//dw_detail 조회
dw_detail.is_where = ls_where
dw_detail.SetRedraw(false)
ll_row = dw_detail.Retrieve()
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -2
End If

ls_status = Trim(dw_detail.Object.status[1])

If ls_status = is_receiptcod Then
	dw_detail.Object.status.protect = 1
	dw_detail.Object.status.Color = RGB(0  ,0  ,0  )
	dw_detail.Object.status.Background.Color = RGB(255,251,240)
Else
	dw_detail.Object.status.protect = 0
	dw_detail.Object.status.Color = RGB(255  ,255  ,255  )
	dw_detail.Object.status.Background.Color = RGB(108,147,137)
End If

dw_detail.SetRedraw(true)

Return 0
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_validkeyreq
boolean visible = false
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_validkeyreq
boolean visible = false
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_validkeyreq
integer x = 41
integer y = 1896
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_validkeyreq
integer x = 357
integer y = 1896
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_validkeyreq
integer x = 14
integer y = 1152
end type

