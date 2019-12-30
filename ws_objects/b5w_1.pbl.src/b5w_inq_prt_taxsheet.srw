$PBExportHeader$b5w_inq_prt_taxsheet.srw
$PBExportComments$[jwlee]세금계산서발행정보조회 및 출력
forward
global type b5w_inq_prt_taxsheet from w_a_inq_m_m
end type
type p_print from u_p_print within b5w_inq_prt_taxsheet
end type
type p_1 from u_p_saveas within b5w_inq_prt_taxsheet
end type
end forward

global type b5w_inq_prt_taxsheet from w_a_inq_m_m
integer width = 3122
integer height = 2032
event ue_print ( )
event ue_saveas ( )
p_print p_print
p_1 p_1
end type
global b5w_inq_prt_taxsheet b5w_inq_prt_taxsheet

type variables
String is_supplyregisternum, is_supplytradename, is_supplyaddr, is_supplybusinesscondition
String is_supplyitem, is_supplyname, is_note, is_list, iS_datekind[], iS_datechoice


end variables

forward prototypes
public function integer wfi_get_shopnm (string shopid)
end prototypes

event ue_print();//프린트 
If dw_detail.Rowcount() <= 0 Then Return
dw_detail.Print()
end event

event ue_saveas();f_excel_ascii1(dw_master,'파일명을 입력하세요.')
end event

public function integer wfi_get_shopnm (string shopid);String ls_shopnm

SELECT shopnm
INTO :ls_shopnm
FROM shopmst
WHERE shopid = :shopid;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Shopmst select error")
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	Return -1
End IF

dw_cond.Object.shopnm[1] = ls_shopnm

Return 0
end function

on b5w_inq_prt_taxsheet.create
int iCurrent
call super::create
this.p_print=create p_print
this.p_1=create p_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_print
this.Control[iCurrent+2]=this.p_1
end on

on b5w_inq_prt_taxsheet.destroy
call super::destroy
destroy(this.p_print)
destroy(this.p_1)
end on

event ue_ok();call super::ue_ok;Long ll_row
String ls_where
String ls_fromdt, ls_todt, ls_sheetno, ls_cregno, ls_customerid
String ls_paydt_fr, ls_paydt_to, ls_type
dw_cond.Accepttext()

ls_paydt_fr   = Trim(String(dw_cond.Object.paydt_fr[1],'yyyymmdd'))//입금일 from
ls_paydt_to   = Trim(String(dw_cond.Object.paydt_to[1],'yyyymmdd'))//입금일 to
ls_fromdt     = Trim(String(dw_cond.Object.fromdt[1],'yyyymmdd'))  //발행일 from
ls_todt       = Trim(String(dw_cond.Object.todt[1],'yyyymmdd'))    //발행일 to
ls_type       = dw_cond.Object.type[1]                             //발행type
ls_sheetno    = dw_cond.Object.sheetno[1]                          //세금계산서번호
ls_cregno     = Trim(dw_cond.Object.shopid[1])                     //사업자번호
ls_customerid = Trim(dw_cond.Object.customerid[1])                 //고객번호

If(IsNull(ls_paydt_fr))   Then ls_paydt_fr   = ""
If(IsNull(ls_paydt_to))   Then ls_paydt_to   = ""
If(IsNull(ls_fromdt))     Then ls_fromdt     = ""
If(IsNull(ls_todt))       Then ls_todt       = ""
If(IsNull(ls_type))       Then ls_type       = ""
If(IsNull(ls_customerid)) Then ls_customerid = ""
If(IsNull(ls_sheetno))    Then ls_sheetno    = ""
If(IsNull(ls_cregno))     Then ls_cregno     = ""

if ls_fromdt <> "" and ls_todt <> "" Then
	If ls_fromdt > ls_todt Then
		f_msg_usr_err(211, title, "발행일자")
		dw_cond.SetFocus()
		dw_cond.SetColumn("fromdt")
		Return
	End If
End If

if ls_paydt_fr <> "" and ls_paydt_to <> "" Then
	If ls_paydt_fr > ls_paydt_to Then
		f_msg_usr_err(211, title, "입금일자")
		dw_cond.SetFocus()
		dw_cond.SetColumn("paydt_fr")
		Return
	End If
End If


//Dynamic SQL
ls_where = ""
If(ls_fromdt <> "" ) Then
      If( ls_where <> "" ) Then ls_where += " AND "
		ls_where += "to_char(taxissuedt, 'YYYYMMDD') >= '"+ ls_fromdt +"'"
End if

If(ls_todt <> "" ) Then
		If( ls_where <> "" ) Then ls_where += " AND "
		ls_where += "to_char(taxissuedt, 'YYYYMMDD') <= '"+ ls_todt +"'"
End if

If(ls_type <> "" ) Then
		If( ls_where <> "" ) Then ls_where += " AND "
		ls_where += "type = '"+ ls_type +"'"
End if

If(ls_paydt_fr <> "" ) Then
      If( ls_where <> "" ) Then ls_where += " AND "
		ls_where += "to_char(paydt, 'YYYYMMDD') >= '"+ ls_paydt_fr +"'"
End if

If(ls_paydt_to <> "" ) Then
		If( ls_where <> "" ) Then ls_where += " AND "
		ls_where += "to_char(paydt, 'YYYYMMDD') <= '"+ ls_paydt_to +"'"
End if

If(ls_customerid <> "" ) Then
		If( ls_where <> "" ) Then ls_where += " AND "
		ls_where += "customerid LIKE '"+'%'+ ls_customerid +"'"
End if

If(ls_sheetno <> "" ) Then
		If( ls_where <> "" ) Then ls_where += " AND "
		ls_where += "to_char(taxsheetseq) LIKE '"+'%'+ ls_sheetno +"'"
End If

If(ls_cregno <> "" ) Then
		If( ls_where <> "" ) Then ls_where += "AND "
		ls_where += "cregno LIKE '"+'%'+ ls_cregno +"'"
End if

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
IF ll_row > 0 THEN
	IF fs_snvl(string(dw_master.object.paydt[1],'yyyymmdd'),' ') = ' ' THEN
		p_print.TriggerEvent("ue_disable")
	ELSE
		p_print.TriggerEvent("ue_enable")
	END IF
END IF

If(ll_row =0 ) Then
    f_msg_info(1000, Title, "")
	 dw_detail.Reset()
	 //dw_detail.Insertrow(0)
ElseIf(ll_row < 0 ) Then
    f_msg_usr_err(2100, Title, "Retrieve()")
	 Return 
End if
		
end event

event open;call super::open;/*------------------------------------------------------------
 	Name  : b5w_inq_prt_taxsheet
	Desc. : 세금계산서 발행
	Date  : 2006.06.07
	Auth. : 이진원
	Ver.  : 1.0
--------------------------------------------------------------*/
String lS_ref_desc, ls_temp
dw_cond.SetFocus()
lS_ref_deSc = ""
iS_SupplyregiSternum = fS_get_control("B0", "A104", ls_ref_desc)//사업자 등록번호
iS_Supplytradename = fS_get_control("B0", "A105", lS_ref_desc)  //상호명
iS_Supplyaddr = fS_get_control("B0", "A102", lS_ref_deSc)       //주소
iS_SupplybuSineSScondition = fS_get_control("B0", "A107", lS_ref_deSc)//업태
iS_Supplyitem = fS_get_control("B0", "A108", lS_ref_deSc)       //업종
iS_Supplyname = fS_get_control("B0", "A106", lS_ref_deSc)       //성명
iS_note = fS_get_control("B0", "A109", lS_ref_deSc)             //비고

ls_temp = fS_get_control("B0", "A110", lS_ref_deSc)             //세금계산서 작성기준일 종류
If ls_temp = "" Then Return 0
fi_cut_string(ls_temp, ";" , iS_datekind[])
iS_datechoice  = fS_get_control("B0", "A111", lS_ref_deSc)      //세금계산서 작성기준일 선택



end event

type dw_cond from w_a_inq_m_m`dw_cond within b5w_inq_prt_taxsheet
integer y = 52
integer width = 2139
integer height = 244
string dataobject = "b5dw_cnd_inq_prt_taxsheet"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init;call super::ue_init;This.idwo_help_col[1] = This.Object.shopid
This.is_help_win[1] = "b1w_hlp_payid"
This.is_data[1] = "CloseWithReturn"

This.idwo_help_col[2] = This.Object.customerid
This.is_help_win[2] = "b1w_hlp_payid"
This.is_data[2] = "CloseWithReturn"


end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "shopid"
		If This.iu_cust_help.ib_data[1] Then
			This.Object.shopid[row] = This.iu_cust_help.is_data[1]
			This.Object.shopnm[row] = This.iu_cust_help.is_data[2]
		End If
		
	Case "customerid"
		If This.iu_cust_help.ib_data[1] Then
			This.Object.customerid[row] = This.iu_cust_help.is_data[1]
		End If
End Choose



end event

event dw_cond::itemchanged;call super::itemchanged;Integer li_rc
String ls_shopid, ls_shopnm

Choose Case dwo.name
	Case "shopid"
		ls_shopid = dw_cond.Object.shopid[1]
		If IsNull(ls_shopid) then ls_shopid = " "
		
//		ls_shopnm= fs_get_shopnm(ls_shopid, title)
//		dw_cond.Object.shopnm[1] = ls_shopnm

End Choose




end event

type p_ok from w_a_inq_m_m`p_ok within b5w_inq_prt_taxsheet
integer x = 2304
integer y = 56
end type

type p_close from w_a_inq_m_m`p_close within b5w_inq_prt_taxsheet
integer x = 2606
integer y = 56
end type

type gb_cond from w_a_inq_m_m`gb_cond within b5w_inq_prt_taxsheet
integer width = 2185
integer height = 312
end type

type dw_master from w_a_inq_m_m`dw_master within b5w_inq_prt_taxsheet
integer y = 332
integer height = 528
string dataobject = "b5dw_master_inq_prt_taxsheet"
end type

event dw_master::ue_init;call super::ue_init;dwObject ldwo_sort

ldwo_sort = THIS.Object.taxsheetseq_t
uf_init( ldwo_sort, "D", RGB(0,0,128) )
end event

event dw_master::clicked;call super::clicked;IF ROW < 1 THEN Return
IF fs_snvl(string(dw_master.object.paydt[row],'yyyymmdd'),' ') = ' ' THEN
	p_print.TriggerEvent("ue_disable")
ELSE
	p_print.TriggerEvent("ue_enable")
END IF
end event

type dw_detail from w_a_inq_m_m`dw_detail within b5w_inq_prt_taxsheet
integer y = 904
integer height = 1016
string dataobject = "b5dw_inq_prt_det_taxsheet"
borderstyle borderstyle = stylebox!
end type

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//조회
String ls_where, ls_sheetno
Long ll_sheetno, ll_row

ls_sheetno = String(dw_master.object.taxsheetseq[al_select_row])

ls_where = ""
ls_where += "taxsheetseq = '" + ls_sheetno + "' "

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row =0  Then
   f_msg_info(1000, Title, "")
ElseIf ll_row < 0   Then
   f_msg_usr_err(2100, Title, "Retrieve()")
	Return -1
End if
		
Return 0
end event

event dw_detail::retrieveend;call super::retrieveend;//Setting
String ls_paydt, ls_isudt
ls_paydt = String(dw_detail.object.paydt[1],'yyyymmdd')
ls_isudt = String(dw_detail.object.taxissuedt[1],'yyyymmdd')

This.object.t_supplyregisternum.Text = Is_supplyregisternum
This.object.t_supplytradename.Text = Is_supplytradename
This.object.t_supplyaddr.Text = Is_supplyaddr
This.object.t_supplybusinesscondition.Text = Is_supplybusinesscondition
This.object.t_supplyitem.Text = Is_supplyitem

IF iS_datechoice = iS_datekind[1] THEN
	This.object.t_yyyy.Text  = LeftA(ls_isudt,4)
	This.object.t_mm.Text    = MidA(ls_isudt,5,2)
	This.object.t_dd.Text    = MidA(ls_isudt,7,2)
	This.object.t_mm1.Text   = MidA(ls_isudt,5,2)
	This.object.t_dd1.Text   = MidA(ls_isudt,7,2)
	This.object.t_yyyy2.Text = LeftA(ls_isudt,4)
	This.object.t_mm2.Text   = MidA(ls_isudt,5,2)
	This.object.t_dd2.Text   = MidA(ls_isudt,7,2)
	This.object.t_mm3.Text   = MidA(ls_isudt,5,2)
	This.object.t_dd3.Text   = MidA(ls_isudt,7,2)
ElSEIF iS_datechoice = iS_datekind[2] THEN
	This.object.t_yyyy.Text  = LeftA(ls_paydt,4)
	This.object.t_mm.Text    = MidA(ls_paydt,5,2)
	This.object.t_dd.Text    = MidA(ls_paydt,7,2)
	This.object.t_mm1.Text   = MidA(ls_paydt,5,2)
	This.object.t_dd1.Text   = MidA(ls_paydt,7,2)
	This.object.t_yyyy2.Text = LeftA(ls_paydt,4)
	This.object.t_mm2.Text   = MidA(ls_paydt,5,2)
	This.object.t_dd2.Text   = MidA(ls_paydt,7,2)
	This.object.t_mm3.Text   = MidA(ls_paydt,5,2)
	This.object.t_dd3.Text   = MidA(ls_paydt,7,2)
END IF

This.object.t_note.Text = Is_note
//This.object.t_list.Text = Is_list

This.object.t_supplyregisternum_1.Text = Is_supplyregisternum
This.object.t_supplytradename_1.Text = Is_supplytradename
This.object.t_supplyaddr_1.Text = Is_supplyaddr
This.object.t_supplybusinesscondition_1.Text = Is_supplybusinesscondition
This.object.t_supplyitem_1.Text = Is_supplyitem
This.object.t_supplyname_1.Text = Is_supplyname

This.object.t_note_1.Text = Is_note
//This.object.t_list_1.Text = Is_list
end event

type st_horizontal from w_a_inq_m_m`st_horizontal within b5w_inq_prt_taxsheet
integer y = 868
end type

type p_print from u_p_print within b5w_inq_prt_taxsheet
integer x = 2304
integer y = 172
boolean bringtotop = true
boolean originalsize = false
end type

type p_1 from u_p_saveas within b5w_inq_prt_taxsheet
integer x = 2606
integer y = 172
boolean bringtotop = true
boolean originalsize = false
end type

