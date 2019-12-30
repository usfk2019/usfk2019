$PBExportHeader$b1w_prt_contractlist.srw
$PBExportComments$[ceusee] 서비스 계약정보 리스트
forward
global type b1w_prt_contractlist from w_a_print
end type
end forward

global type b1w_prt_contractlist from w_a_print
integer width = 4155
integer height = 2128
end type
global b1w_prt_contractlist b1w_prt_contractlist

forward prototypes
public function integer wfI_get_partner (string as_partner)
public function integer wfi_get_customerid (string as_customerid)
end prototypes

public function integer wfI_get_partner (string as_partner);String ls_partnernm

Select partnernm
Into :ls_partnernm
From partnermst
Where partner = :as_partner and act_yn ='Y';

If SQLCA.SQLCODE = 100 Then
	Return -1
End If

Return 0
end function

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
  	dw_cond.object.customernm[1] = ""
 Return -1
End If

dw_cond.object.customernm[1] = ls_customernm
Return 0

end function

event ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

on b1w_prt_contractlist.create
call super::create
end on

on b1w_prt_contractlist.destroy
call super::destroy
end on

event ue_init;call super::ue_init;ii_orientation = 1 //가로 기준
ib_margin = True
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b1w_prt_contractlist
	Desc.	: 서비스 계약 리스트
	Date	: 2002.10.6
	Ver.	: 1.0
	Programer : Choi Bo Ra(ceusee)
-------------------------------------------------------------------------*/
end event

event ue_ok;call super::ue_ok;//조회
String ls_customerid, ls_svccod, ls_priceplan, ls_prmtype
String ls_reg_partner, ls_partner, ls_settle_partner, ls_maintain_partner
String ls_sale_partner, ls_contractseq
String ls_contractno, ls_status, ls_bil_fromdt, ls_bil_todt, ls_where
Long ll_row
Integer li_check
Date ld_bil_fromdt, ld_bil_todt

ls_customerid = Trim(dw_cond.object.customerid[1])
ls_status = Trim(dw_cond.object.status[1])
ls_svccod = Trim(dw_cond.object.svccod[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_prmtype = Trim(dw_cond.object.prmtype[1])
ls_contractno = Trim(dw_cond.object.contractno[1])
ls_partner = Trim(dw_cond.object.partner[1])
ls_reg_partner = Trim(dw_cond.object.reg_partner[1])
ls_maintain_partner = Trim(dw_cond.object.maintain_partner[1])
ls_settle_partner = Trim(dw_cond.object.settle_partner[1])
ls_sale_partner = Trim(dw_cond.object.sale_partner[1])
ls_contractseq = String(dw_cond.object.contractseq[1])
ls_bil_fromdt = String(dw_cond.object.bil_fromdt[1],'yyyymmdd')
ls_bil_todt = String(dw_cond.object.bil_todt[1],'yyyymmdd')
ld_bil_fromdt = dw_cond.object.bil_fromdt[1]
ld_bil_todt = dw_cond.object.bil_todt[1]

If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_contractseq) Then ls_contractseq = ""
If IsNull(ls_status) Then ls_status = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_svccod) Then ls_svccod = ""
If IsNull(ls_prmtype) Then ls_prmtype = ""
If IsNull(ls_partner) Then ls_partner = ""
If IsNull(ls_reg_partner) Then ls_reg_partner = ""
If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""
If IsNull(ls_settle_partner) Then ls_settle_partner = ""
If IsNull(ls_sale_partner) Then ls_sale_partner = ""
If IsNull(ls_bil_fromdt) Then ls_bil_fromdt = ""
If IsNull(ls_bil_todt) Then ls_bil_todt = ""

ls_where = ""
If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cmt.customerid = '" + ls_customerid + "' "
End If

If ls_status <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cmt.status = '" + ls_status + "' "
End If

If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cmt.svccod = '" + ls_svccod + "' "
End If

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cmt.priceplan = '" + ls_priceplan+ "' "
End If

If ls_prmtype <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cmt.prmtype = '" + ls_prmtype + "' "
End If

If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cmt.partner = '" + ls_partner + "' "
End If

If ls_reg_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cmt.reg_partner = '" + ls_reg_partner + "' "
End If

If ls_settle_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cmt.settle_partner = '" + ls_settle_partner + "' "
End If

If ls_maintain_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cmt.maintain_partner = '" + ls_maintain_partner + "' "
End If

If ls_sale_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cmt.sale_partner = '" + ls_sale_partner + "' "
End If

If ls_contractno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cmt.contractno = '" + ls_contractno + "' "
End If

If ls_contractseq <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(cmt.contractseq) like '" + ls_contractseq + "%' "
End If

If ls_bil_fromdt <> ""  and ls_bil_todt <> "" Then
	li_check = fi_chk_frto_day(ld_bil_fromdt, ld_bil_todt)
	If li_check <> -3 and li_check < 0 Then
		f_msg_usr_err(211, Title, "과금기간")
		dw_cond.SetFocus()
		dw_cond.SetColumn("bil_fromdt")
		Return
	Else
		If ls_where <> "" Then ls_where += " And "
		ls_where += "decode(to_char(cmt.bil_todt,'yyyymmdd'), null, " + ls_bil_todt + &
		             ", to_char(cmt.bil_todt,'yyyymmdd')) <= '" + ls_bil_todt + "' And " + &
						 ls_bil_fromdt + " <= to_char(cmt.bil_fromdt, 'yyyymmdd') "  
	
	End If
	
ElseIf ls_bil_fromdt <> "" And ls_bil_todt = "" Then
	If ls_where <> "" Then ls_where += " And "
		ls_where += "to_char(cmt.bil_fromdt,'yyyymmdd') >= '" + ls_bil_fromdt + "' " 
						
ElseIf ls_bil_fromdt = "" And ls_bil_todt <> "" Then
	If ls_where <> "" Then ls_where += " And "
		ls_where += "decode(to_char(cmt.bil_todt,'yyyymmdd'), null, " + ls_bil_todt + &
		             ", to_char(cmt.bil_todt,'yyyymmdd')) <= '" + ls_bil_todt + "' "
End If

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()
If ll_row = 0 Then
		f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

end event

type dw_cond from w_a_print`dw_cond within b1w_prt_contractlist
integer x = 50
integer width = 3342
integer height = 588
string dataobject = "b1dw_cnd_prt_contractlist"
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
			 dw_cond.iu_cust_help.is_data[2]
		End If
	Case "maintain_partner"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.maintain_partner[row] = &
			 dw_cond.iu_cust_help.is_data[1]
			  dw_cond.Object.maintain_partnernm[row] = &
			 dw_cond.iu_cust_help.is_data[2]
		End If
	Case "sale_partner"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.sale_partner[row] = &
			 dw_cond.iu_cust_help.is_data[1]
			  dw_cond.Object.sale_partnernm[row] = &
			 dw_cond.iu_cust_help.is_data[2]
		End If
End Choose

Return 0 
end event

event dw_cond::itemchanged;call super::itemchanged;Choose Case dwo.name
	Case "customerid"
   		wfi_get_customerid(data)
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

event dw_cond::ue_init;//Help Window
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

type p_ok from w_a_print`p_ok within b1w_prt_contractlist
integer x = 3515
integer y = 64
end type

type p_close from w_a_print`p_close within b1w_prt_contractlist
integer x = 3808
integer y = 64
end type

type dw_list from w_a_print`dw_list within b1w_prt_contractlist
integer y = 660
integer width = 4055
integer height = 1092
string dataobject = "b1dw_prt_contractlist"
end type

type p_1 from w_a_print`p_1 within b1w_prt_contractlist
integer x = 3790
integer y = 1788
end type

type p_2 from w_a_print`p_2 within b1w_prt_contractlist
integer y = 1792
end type

type p_3 from w_a_print`p_3 within b1w_prt_contractlist
integer x = 3493
integer y = 1788
end type

type p_5 from w_a_print`p_5 within b1w_prt_contractlist
integer x = 1637
integer y = 1792
end type

type p_6 from w_a_print`p_6 within b1w_prt_contractlist
integer x = 2254
integer y = 1792
end type

type p_7 from w_a_print`p_7 within b1w_prt_contractlist
integer x = 2048
integer y = 1792
end type

type p_8 from w_a_print`p_8 within b1w_prt_contractlist
integer x = 1842
integer y = 1792
end type

type p_9 from w_a_print`p_9 within b1w_prt_contractlist
integer y = 1792
end type

type p_4 from w_a_print`p_4 within b1w_prt_contractlist
end type

type gb_1 from w_a_print`gb_1 within b1w_prt_contractlist
integer y = 1756
end type

type p_port from w_a_print`p_port within b1w_prt_contractlist
integer y = 1812
end type

type p_land from w_a_print`p_land within b1w_prt_contractlist
integer y = 1824
end type

type gb_cond from w_a_print`gb_cond within b1w_prt_contractlist
integer width = 3365
integer height = 652
end type

type p_saveas from w_a_print`p_saveas within b1w_prt_contractlist
integer x = 3195
integer y = 1788
end type

