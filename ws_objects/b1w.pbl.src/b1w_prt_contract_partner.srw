$PBExportHeader$b1w_prt_contract_partner.srw
$PBExportComments$[kem] 대리점별 계약건수 리스트
forward
global type b1w_prt_contract_partner from w_a_print
end type
end forward

global type b1w_prt_contract_partner from w_a_print
integer width = 3026
integer height = 2128
end type
global b1w_prt_contract_partner b1w_prt_contract_partner

type variables
String is_status, is_sus_status
Long   il_leng
end variables

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

on b1w_prt_contract_partner.create
call super::create
end on

on b1w_prt_contract_partner.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 2 //세로 기준
ib_margin = True
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b1w_prt_contract_partner
	Desc.	: 파트너별 서비스 계약 건수 리스트
	Date	: 2004.01.28
	Ver.	: 1.0
	Programer : Kim eun mi(kem)
-------------------------------------------------------------------------*/
String ls_ref_desc, ls_temp, ls_result[], ls_level

//개통상태
is_status = fs_get_control('B0', 'P223', ls_ref_desc)

//일시정지상태
ls_temp = fs_get_control('B0', 'P225', ls_ref_desc)
fi_cut_string(ls_temp, ';', ls_result[])
is_sus_status = ls_result[2]

//관리대상Level
ls_level = fs_get_control('A1', 'C100', ls_ref_desc)

select max(lengthb(prefixno))
  into :il_leng
  from partnermst
 where levelcod = :ls_level;
 
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "")
	dw_cond.SetFocus()
	dw_cond.SetColumn("reg_partner")
End If







end event

event ue_ok();call super::ue_ok;//조회
String ls_svccod, ls_priceplan, ls_reg_partner, ls_where, ls_gubun
String ls_fromdt, ls_todt
Long ll_row
Integer li_check
Date ld_fromdt, ld_todt

ls_gubun       = Trim(dw_cond.Object.gubun[1])
ls_svccod      = Trim(dw_cond.object.svccod[1])
ls_priceplan   = Trim(dw_cond.object.priceplan[1])
ls_reg_partner = Trim(dw_cond.object.reg_partner[1])

ls_fromdt = String(dw_cond.object.fromdt[1],'yyyymmdd')
ls_todt = String(dw_cond.object.todt[1],'yyyymmdd')
ld_fromdt = dw_cond.object.fromdt[1]
ld_todt = dw_cond.object.todt[1]

If IsNull(ls_svccod) Then ls_svccod = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_reg_partner) Then ls_reg_partner = ""
If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_todt) Then ls_todt = ""

ls_where = ""
If ls_where <> "" Then ls_where += " And "
ls_where += " a.status in ('" + is_status + "', '" + is_sus_status + "') "

If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.svccod = '" + ls_svccod + "' "
End If

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.priceplan = '" + ls_priceplan + "' "
End If

If ls_reg_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " b.partner = '" + ls_reg_partner + "' "
End If

If ls_fromdt <> ""  and ls_todt <> "" Then
	li_check = fi_chk_frto_day(ld_fromdt, ld_todt)
	If li_check <> -3 and li_check < 0 Then
		f_msg_usr_err(211, Title, "개통일자")
		dw_cond.SetFocus()
		dw_cond.SetColumn("fromdt")
		Return
	Else
		If ls_where <> "" Then ls_where += " And "
		ls_where += " to_char(a.activedt,'yyyymmdd') >= " + ls_fromdt + &
		             " And to_char(a.activedt,'yyyymmdd') <= '" + ls_todt + "' "  
	
	End If
	
ElseIf ls_fromdt <> "" And ls_todt = "" Then
	If ls_where <> "" Then ls_where += " And "
		ls_where += " to_char(a.activedt,'yyyymmdd') >= '" + ls_fromdt + "' " 
						
ElseIf ls_fromdt = "" And ls_todt <> "" Then
	If ls_where <> "" Then ls_where += " And "
		ls_where += " to_char(a.activedt,'yyyymmdd') <= '" + ls_todt + "' "
End If


//데이터 윈도우 바꾸기 
If ls_gubun = "0" Then
	dw_list.DataObject = "b1dw_prt_contract_partner"
	dw_list.SetTransObject(SQLCA)
Else
	dw_list.DataObject = "b1dw_prt_contract_partner1"
	dw_list.SetTransObject(SQLCA)
End If

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve(il_leng)
If ll_row = 0 Then
		f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

//조건셋팅
If ls_fromdt <> "" And ls_todt <> "" Then
	dw_list.Object.t_date.Text = LeftA(ls_fromdt,4) + '-' + MidA(ls_fromdt,5,2) + '-' + RightA(ls_fromdt,2) + ' ~~ ' +  LeftA(ls_todt,4) + '-' + MidA(ls_todt,5,2) + '-' + RightA(ls_todt,2)
										  
ElseIf ls_fromdt <> "" And ls_todt = "" Then
	dw_list.Object.t_date.Text = LeftA(ls_fromdt,4) + '-' + MidA(ls_fromdt,5,2) + '-' + RightA(ls_fromdt,2) + ' ~~ '
	
ElseIf ls_fromdt = "" And ls_todt <> "" Then
	dw_list.Object.t_date.Text = "          " + ' ~~ ' +  LeftA(ls_todt,4) + '-' + MidA(ls_todt,5,2) + '-' + RightA(ls_todt,2)
End If
end event

event ue_reset();call super::ue_reset;dw_cond.Object.gubun[1] = '0'
end event

type dw_cond from w_a_print`dw_cond within b1w_prt_contract_partner
integer x = 55
integer width = 1563
integer height = 440
string dataobject = "b1dw_cnd_prt_contract_partner"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b1w_prt_contract_partner
integer x = 1755
integer y = 64
end type

type p_close from w_a_print`p_close within b1w_prt_contract_partner
integer x = 2048
integer y = 64
end type

type dw_list from w_a_print`dw_list within b1w_prt_contract_partner
integer y = 524
integer width = 2903
integer height = 1212
string dataobject = "b1dw_prt_contract_partner1"
end type

type p_1 from w_a_print`p_1 within b1w_prt_contract_partner
integer x = 3186
integer y = 1788
end type

type p_2 from w_a_print`p_2 within b1w_prt_contract_partner
integer y = 1792
end type

type p_3 from w_a_print`p_3 within b1w_prt_contract_partner
integer x = 2889
integer y = 1788
end type

type p_5 from w_a_print`p_5 within b1w_prt_contract_partner
integer x = 1454
integer y = 1792
end type

type p_6 from w_a_print`p_6 within b1w_prt_contract_partner
integer x = 2071
integer y = 1792
end type

type p_7 from w_a_print`p_7 within b1w_prt_contract_partner
integer x = 1865
integer y = 1792
end type

type p_8 from w_a_print`p_8 within b1w_prt_contract_partner
integer x = 1659
integer y = 1792
end type

type p_9 from w_a_print`p_9 within b1w_prt_contract_partner
integer y = 1792
end type

type p_4 from w_a_print`p_4 within b1w_prt_contract_partner
end type

type gb_1 from w_a_print`gb_1 within b1w_prt_contract_partner
integer y = 1756
end type

type p_port from w_a_print`p_port within b1w_prt_contract_partner
integer y = 1812
end type

type p_land from w_a_print`p_land within b1w_prt_contract_partner
integer y = 1824
end type

type gb_cond from w_a_print`gb_cond within b1w_prt_contract_partner
integer width = 1605
integer height = 504
end type

type p_saveas from w_a_print`p_saveas within b1w_prt_contract_partner
integer x = 2592
integer y = 1788
end type

