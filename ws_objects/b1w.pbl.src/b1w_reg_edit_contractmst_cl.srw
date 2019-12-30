$PBExportHeader$b1w_reg_edit_contractmst_cl.srw
$PBExportComments$[kem] 계약내역조회/수정 - C&L
forward
global type b1w_reg_edit_contractmst_cl from w_a_reg_m_m
end type
end forward

global type b1w_reg_edit_contractmst_cl from w_a_reg_m_m
integer width = 4398
integer height = 2124
end type
global b1w_reg_edit_contractmst_cl b1w_reg_edit_contractmst_cl

type variables
String is_priceplan		//Price Plan Code
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

on b1w_reg_edit_contractmst_cl.create
call super::create
end on

on b1w_reg_edit_contractmst_cl.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_edit_contractmst
	Desc.	: 	계약내역조회/수정
	Ver.	:	1.0
	Date	: 	2002.10.13
	Programer : Park Kyung Hae(Parkkh)
--------------------------------------------------------------------------*/

end event

event ue_ok();call super::ue_ok;//해당 서비스에 해당하는 품목 조회
String ls_svccod, ls_priceplan, ls_customerid, ls_reg_partner, ls_maintain_partner, ls_prmtype
String ls_where, ls_activedt_fr, ls_activedt_to, ls_status, ls_contractseq, ls_contractno, ls_sale_partner
Long ll_row

ls_customerid = Trim(dw_cond.object.customerid[1])
ls_status = Trim(dw_cond.object.status[1])
ls_contractseq = Trim(dw_cond.object.contractseq[1])
ls_contractno = Trim(dw_cond.object.contractno[1])
ls_svccod = Trim(dw_cond.object.svccod[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_prmtype = Trim(dw_cond.object.prmtype[1])
ls_reg_partner = Trim(dw_cond.object.reg_partner[1])
ls_sale_partner = Trim(dw_cond.object.sale_partner[1])
ls_maintain_partner = Trim(dw_cond.object.maintain_partner[1])
ls_activedt_fr = String(dw_cond.object.activedt_fr[1],'yyyymmdd')
ls_activedt_to = String(dw_cond.object.activedt_to[1],'yyyymmdd')

If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_status) Then ls_status = ""
If IsNull(ls_contractseq) Then ls_contractseq = ""
If IsNull(ls_contractno) Then ls_contractno = ""
If IsNull(ls_svccod) Then ls_svccod = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_prmtype) Then ls_prmtype = ""
If IsNull(ls_reg_partner) Then ls_reg_partner = ""
If IsNull(ls_sale_partner) Then ls_sale_partner = ""
If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""
If IsNull(ls_activedt_fr) Then ls_activedt_fr = ""
If IsNull(ls_activedt_to) Then ls_activedt_to = ""

If ls_activedt_fr <> "" And ls_activedt_to <> "" Then
	If ls_activedt_fr > ls_activedt_to Then
		f_msg_usr_err(201, Title, "Activation Date")
		dw_cond.SetFocus()
		dw_cond.SetColumn("activedt_fr")
	   Return
	End If
End If

IF ls_customerid <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "con.customerid = '" + ls_customerid + "' "
End If

IF ls_status <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "con.status = " + ls_status + " "
End If

IF ls_contractseq <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "con.contractseq = " + ls_contractseq + " "
End If

IF ls_contractno <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "con.contractno like '" + ls_contractno + "%' "
End If

IF ls_svccod <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "con.svccod= '" + ls_svccod + "' "
End If

IF ls_priceplan <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "con.priceplan= '" + ls_priceplan + "' "
End If

IF ls_prmtype <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "con.prmtype= '" + ls_prmtype + "' "
End If

IF ls_reg_partner <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "con.reg_partner= '" + ls_reg_partner + "' "
End If

IF ls_sale_partner <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "con.sale_partner= '" + ls_sale_partner + "' "
End If

IF ls_maintain_partner <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "con.maintain_partner= '" + ls_maintain_partner + "' "
End If

If ls_activedt_fr <> "" Then
  If ls_where <> "" Then ls_where += " And "  
  ls_where += "to_char(con.activedt,'YYYYMMDD') >='" + ls_activedt_fr + "' " 
End if

If ls_activedt_to <> "" Then
  If ls_where <> "" Then ls_where += " And "  
  ls_where += "to_char(con.activedt,'YYYYMMDD') <='" + ls_activedt_to + "' " 
End if

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title , "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
   Return
End If
end event

event type integer ue_extra_save();call super::ue_extra_save;//Save Check
String ls_itemcod, ls_fromdt, ls_todt, ls_method
Long ll_rows , i

dw_detail.AcceptText()
ll_rows = dw_detail.RowCount()
If ll_rows = 0 Then Return 0

ls_fromdt = string(dw_detail.object.contractmst_bil_fromdt[1],'yyyymmdd')
ls_todt = string(dw_detail.object.contractmst_bil_todt[1],'yyyymmdd')

//Null Check
If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_todt) Then ls_todt = ""

If ls_fromdt = "" Then
	f_msg_usr_err(200, Title, "과금시작일")
	dw_detail.SetFocus()
	dw_detail.SetColumn("contractmst_bil_fromdt")
	Return -2
End If

//If ls_todt = "" Then
//	f_msg_usr_err(200, Title, "과금종료일")
//	dw_detail.SetFocus()
//	dw_detail.SetColumn("contractmst_bil_todt")
//	Return -2
//End If

////// 날짜 체크
If ls_todt <> "" Then
	If ls_fromdt > ls_todt Then
		f_msg_usr_err(210, Title, "'과금종료일은 과금시작일보다 크거나 같아야 합니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("contractmst_bil_todt")
		Return -2
	End If		
End If

If dw_detail.GetItemStatus(1, 0, Primary!) = DataModified! THEN
	dw_detail.object.contractmst_updt_user[1] = gs_user_id
	dw_detail.object.contractmst_updtdt[1] = fdt_get_dbserver_now()
End If
	
Return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_edit_contractmst_cl
integer x = 55
integer width = 3616
integer height = 456
string dataobject = "b1dw_cnd_reg_edit_contractmst"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.customerid[row] = &
			 dw_cond.iu_cust_help.is_data[1]
			 dw_cond.object.customernm[row] = &
			 dw_cond.iu_cust_help.is_data[2]
		End If
	Case "reg_partner"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.reg_partner[row] = &
			 dw_cond.iu_cust_help.is_data[1]
			  dw_cond.Object.reg_partnernm[row] = &
			 dw_cond.iu_cust_help.is_data[1]
		End If
	Case "maintain_partner"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.maintain_partner[row] = &
			 dw_cond.iu_cust_help.is_data[1]
			  dw_cond.Object.maintain_partnernm[row] = &
			 dw_cond.iu_cust_help.is_data[1]
		End If
	Case "sale_partner"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.sale_partner[row] = &
			 dw_cond.iu_cust_help.is_data[1]
			  dw_cond.Object.sale_partnernm[row] = &
			 dw_cond.iu_cust_help.is_data[1]
		End If
End Choose

Return 0 
end event

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild ldc_priceplan, ldc_svcpromise
Long li_exist
String ls_filter, ls_customernm

Choose Case dwo.name
	Case "customerid"
		
		 If data = "" then 
				This.Object.customernm[row] = ""			
				This.SetFocus()
				This.SetColumn("customerid")
				Return -1
 		 End If		 
		 
		 SELECT customernm
		 INTO :ls_customernm
		 FROM customerm
		 WHERE customerid = :data ;
		 If SQLCA.SQLCode < 0 Then
			 f_msg_sql_err(parent.Title,"select 고객명")
			 Return 1
		 End If		 
		 
		 If ls_customernm = "" or isnull(ls_customernm ) then
//				This.Object.customerid[row] = ""
				This.Object.customernm[row] = ""
				This.SetFocus()
				This.SetColumn("customerid")
				Return -1
		 End if
		 
		 This.Object.customernm[row] = ls_customernm
			
	Case "maintain_partner"
		If wfi_get_partner(data)  = -1 Then
			Object.maintain_partnernm[1] = ""
		Else
			Object.maintain_partnernm[1] = data
		End IF
	Case "reg_partner"
		If wfi_get_partner(data)  = -1 Then
			Object.reg_partnernm[1] = ""
		Else
			Object.reg_partnernm[1] = data
		End IF
		
	Case "sale_partner"
		If wfi_get_partner(data)  = -1 Then
			Object.sale_partnernm[1] = ""
		Else
			Object.sale_partnernm[1] = data
		End IF
End Choose	
end event

event dw_cond::ue_init();call super::ue_init;//Help Window
This.idwo_help_col[1] = This.Object.customerid
This.is_help_win[1] = "b1w_hlp_customerm"
This.is_data[1] = "CloseWithReturn"

//유치파트너
This.idwo_help_col[2] = This.Object.reg_partner
This.is_help_win[2] = "b1w_hlp_partner"
This.is_data[2] = "CloseWithReturn"

//관리
This.idwo_help_col[3] = This.Object.maintain_partner
This.is_help_win[3] = "b1w_hlp_partner"
This.is_data[3] = "CloseWithReturn"

//매출 파트너 
This.idwo_help_col[4] = This.Object.sale_partner
This.is_help_win[4] = "b1w_hlp_partner"
This.is_data[4] = "CloseWithReturn"
end event

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_edit_contractmst_cl
integer x = 3749
integer y = 60
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_edit_contractmst_cl
integer x = 4050
integer y = 60
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_edit_contractmst_cl
integer width = 3657
integer height = 516
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_edit_contractmst_cl
integer x = 23
integer y = 532
integer width = 4293
integer height = 636
string dataobject = "b1dw_inq_edit_contractmst"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.contractmst_customerid_t
uf_init(ldwo_sort)
end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_edit_contractmst_cl
integer x = 23
integer y = 1196
integer width = 4288
integer height = 660
string dataobject = "b1dw_reg_edit_contractmst_cl"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//dw_master cleck시 Retrieve
String ls_where, ls_contractseq, ls_termtype, ls_partner, ls_partnernm
Long ll_row
Dec ldc_contractseq
DateTime ldt_termdt

ldc_contractseq = dw_master.object.contractmst_contractseq[al_select_row]
ls_contractseq = string(ldc_contractseq)
If IsNull(ldc_contractseq) Then ls_contractseq = ""
ls_where = ""
If ls_contractseq <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "con.contractseq = " + ls_contractseq + ""
End If

//dw_detail 조회
dw_detail.is_where = ls_where
dw_detail.SetRedraw(false)
ll_row = dw_detail.Retrieve()
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -2
End If

dw_detail.SetRedraw(true)

Return 0
end event

event dw_detail::buttonclicked;call super::buttonclicked;//Butonn Click
Dec ldc_contractseq

Choose Case dwo.Name
		
	Case "item_detail" //상세품목조회
		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "상세품목조회"
		iu_cust_msg.is_grp_name = "계약내역조회/수정"
		iu_cust_msg.is_data[1] = Trim(String(Object.contractmst_contractseq[1]))
		OpenWithParm(b1w_inq_termorder_popup, iu_cust_msg)
		
End Choose

Return 0 
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_edit_contractmst_cl
boolean visible = false
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_edit_contractmst_cl
boolean visible = false
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_edit_contractmst_cl
integer x = 41
integer y = 1896
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_edit_contractmst_cl
integer x = 357
integer y = 1896
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_edit_contractmst_cl
integer x = 14
integer y = 1164
end type

