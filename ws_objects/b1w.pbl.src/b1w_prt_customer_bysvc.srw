$PBExportHeader$b1w_prt_customer_bysvc.srw
$PBExportComments$[parkkh] 서비스별 계약고객 리스트
forward
global type b1w_prt_customer_bysvc from w_a_print
end type
end forward

global type b1w_prt_customer_bysvc from w_a_print
integer width = 4416
integer height = 1904
end type
global b1w_prt_customer_bysvc b1w_prt_customer_bysvc

forward prototypes
public function integer wfi_get_partner (string as_partner)
end prototypes

public function integer wfi_get_partner (string as_partner);String ls_partnernm

Select partnernm
Into :ls_partnernm
From partnermst
Where partner = :as_partner
  and partner_type ='0';

If SQLCA.SQLCODE = 100 Then
	Return -1
End If

Return 0
end function

on b1w_prt_customer_bysvc.create
call super::create
end on

on b1w_prt_customer_bysvc.destroy
call super::destroy
end on

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 1 //세로2, 가로1
ib_margin = False

end event

event ue_ok();call super::ue_ok;//조회
String ls_where, ls_svccod, ls_status, ls_priceplan, ls_ctype1, ls_ctype2, ls_settlepart
String ls_ctype3, ls_regpart, ls_mainpart, ls_salepart, ls_activedt_fr, ls_activedt_to
Date ld_activedt_fr, ld_activedt_to
Long ll_row
boolean lb_check

ls_svccod = Trim(dw_cond.object.svccod[1])
ls_status = Trim(dw_cond.object.status[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_ctype1 = Trim(dw_cond.object.ctype1[1])
ls_ctype2 = Trim(dw_cond.object.ctype2[1])
ls_settlepart = Trim(dw_cond.object.settle_partner[1])
ls_regpart = Trim(dw_cond.object.reg_partner[1])
ls_mainpart = Trim(dw_cond.object.maintain_partner[1])
ls_salepart = Trim(dw_cond.object.sale_partner[1])
ld_activedt_fr = dw_cond.object.activedt_fr[1]
ld_activedt_to = dw_cond.object.activedt_to[1]
ls_activedt_fr = String(ld_activedt_fr, 'yyyymmdd')
ls_activedt_to = String(ld_activedt_to, 'yyyymmdd')

If IsNull(ls_svccod) Then ls_svccod = ""
If IsNull(ls_status) Then ls_status = ""
If IsNull(ls_priceplan) Then ls_priceplan =  ""
If IsNull(ls_ctype1) Then ls_ctype1 = ""
If IsNull(ls_ctype2) Then ls_ctype2 = ""
If IsNull(ls_regpart) Then ls_regpart = ""
If IsNull(ls_settlepart) Then ls_settlepart = ""
If IsNull(ls_mainpart) Then ls_mainpart = ""
If IsNull(ls_salepart) Then ls_salepart = ""
If IsNull(ls_activedt_fr) Then ls_activedt_fr = ""
If IsNull(ls_activedt_to) Then ls_activedt_to = ""

////// 날짜 체크
If ls_activedt_fr <> "" Then 
	lb_check = fb_chk_stringdate(ls_activedt_fr)
	If Not lb_check Then 
		f_msg_usr_err(210, This.Title, "'개통일자(from)'의 날짜 포맷 오류입니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("activedt_fr")
		Return
	End If
End if
		
If ls_activedt_to <> "" Then 
	lb_check = fb_chk_stringdate(ls_activedt_to)
	If Not lb_check Then 
		f_msg_usr_err(210, This.Title, "'개통일자(to)'의 날짜 포맷 오류입니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("activedt_to")
		Return
	End If
End if
		
If ls_activedt_fr <> "" and ls_activedt_to <> "" Then
	If ls_activedt_fr > ls_activedt_to Then
		f_msg_usr_err(221, This.Title, "'개통일자의 from날짜가 to날짜보다 작아야 합니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("activedt_fr")
		Return
	End if
End if

ls_where = ""
If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "contractmst.svccod = '" + ls_svccod + "' " 
End If

If ls_status <> "" Then
	If ls_where <> "" Then ls_where += " And " 
	ls_where += "contractmst.status = '" + ls_status + "' "
End If

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And " 
	ls_where += "contractmst.priceplan = '" + ls_priceplan + "' "
End If

If ls_ctype1 <> "" Then
	If ls_where <> "" Then ls_where += " And " 
	ls_where += "customerm.ctype1 = '" + ls_ctype1 + "' "
End If

If ls_ctype2 <> "" Then
	If ls_where <> "" Then ls_where += " And " 
	ls_where += "customerm.ctype2 = '" + ls_ctype2 + "' "
End If

If ls_settlepart <> "" Then
	If ls_where <> "" Then ls_where += " And " 
	ls_where += "contractmst.settle_partner = '" + ls_settlepart + "' "
End If

If ls_regpart <> "" Then
	If ls_where <> "" Then ls_where += " And " 
	ls_where += "contractmst.reg_partner = '" + ls_regpart + "' "
End If

If ls_mainpart <> "" Then
	If ls_where <> "" Then ls_where += " And " 
	ls_where += "contractmst.maintain_partner = '" + ls_mainpart + "' "
End If

If ls_salepart <> "" Then
	If ls_where <> "" Then ls_where += " And " 
	ls_where += "contractmst.sale_partner = '" + ls_salepart + "' "
End If

If ls_activedt_fr <> "" Then
	If ls_where <> "" Then ls_where += " And " 
	ls_where += "to_char(contractmst.activedt,'yyyymmdd') >= '" + ls_activedt_fr + "' "
End If

If ls_activedt_to <> "" Then
	If ls_where <> "" Then ls_where += " And " 
	ls_where += "to_char(contractmst.activedt,'yyyymmdd') <= '" + ls_activedt_to + "' "
End If

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If
end event

event ue_saveas_init;call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b1w_prt_customer_bysvc
	Desc.	: 서비스별 계약고객 리스트
	Date	: 2002.09.27
	Ver.	: 1.0
	Programer : Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/
//date ld_sysdate
//
//ld_sysdate = Date(fdt_get_dbserver_now())
//
//dw_cond.Object.activedt_fr[1] = ld_sysdate
//dw_cond.Object.activedt_to[1] = ld_sysdate


end event

event ue_reset();call super::ue_reset;date ld_sysdate

//dw_cond.SetRedraw(False)

//ld_sysdate = Date(fdt_get_dbserver_now())
//dw_cond.Object.activedt_fr[1] = ld_sysdate
//dw_cond.Object.activedt_to[1] = ld_sysdate
//
//dw_cond.SetRedraw(True)
end event

type dw_cond from w_a_print`dw_cond within b1w_prt_customer_bysvc
integer x = 46
integer y = 36
integer width = 3849
integer height = 376
string dataobject = "b1dw_cnd_prt_customer_bysvc"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild ldc_priceplan, ldc_svcpromise
Long li_exist
String ls_filter, ls_customernm

Choose Case dwo.name
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

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
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

event dw_cond::ue_init();call super::ue_init;//Help Window
//유치파트너
This.idwo_help_col[1] = This.Object.reg_partner
This.is_help_win[1] = "b1w_hlp_partner"
This.is_data[1] = "CloseWithReturn"

//관리
This.idwo_help_col[2] = This.Object.maintain_partner
This.is_help_win[2] = "b1w_hlp_partner"
This.is_data[2] = "CloseWithReturn"

//매출 파트너 
This.idwo_help_col[3] = This.Object.sale_partner
This.is_help_win[3] = "b1w_hlp_partner"
This.is_data[3] = "CloseWithReturn"
end event

type p_ok from w_a_print`p_ok within b1w_prt_customer_bysvc
integer x = 4018
integer y = 32
end type

type p_close from w_a_print`p_close within b1w_prt_customer_bysvc
integer x = 4018
integer y = 144
end type

type dw_list from w_a_print`dw_list within b1w_prt_customer_bysvc
integer x = 41
integer y = 476
integer width = 4315
integer height = 1060
string dataobject = "b1dw_prt_customer_bysvc"
end type

type p_1 from w_a_print`p_1 within b1w_prt_customer_bysvc
integer y = 1592
end type

type p_2 from w_a_print`p_2 within b1w_prt_customer_bysvc
integer y = 1592
end type

type p_3 from w_a_print`p_3 within b1w_prt_customer_bysvc
integer y = 1592
end type

type p_5 from w_a_print`p_5 within b1w_prt_customer_bysvc
integer y = 1592
end type

type p_6 from w_a_print`p_6 within b1w_prt_customer_bysvc
integer y = 1592
end type

type p_7 from w_a_print`p_7 within b1w_prt_customer_bysvc
integer y = 1592
end type

type p_8 from w_a_print`p_8 within b1w_prt_customer_bysvc
integer y = 1592
end type

type p_9 from w_a_print`p_9 within b1w_prt_customer_bysvc
integer y = 1592
end type

type p_4 from w_a_print`p_4 within b1w_prt_customer_bysvc
end type

type gb_1 from w_a_print`gb_1 within b1w_prt_customer_bysvc
integer y = 1552
end type

type p_port from w_a_print`p_port within b1w_prt_customer_bysvc
integer y = 1616
end type

type p_land from w_a_print`p_land within b1w_prt_customer_bysvc
integer y = 1628
end type

type gb_cond from w_a_print`gb_cond within b1w_prt_customer_bysvc
integer width = 3872
integer height = 440
end type

type p_saveas from w_a_print`p_saveas within b1w_prt_customer_bysvc
integer y = 1592
end type

