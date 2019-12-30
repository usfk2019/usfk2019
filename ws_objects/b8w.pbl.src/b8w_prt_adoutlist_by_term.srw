$PBExportHeader$b8w_prt_adoutlist_by_term.srw
$PBExportComments$[parkkh] 일자별이동리스트
forward
global type b8w_prt_adoutlist_by_term from w_a_print
end type
end forward

global type b8w_prt_adoutlist_by_term from w_a_print
integer width = 3982
end type
global b8w_prt_adoutlist_by_term b8w_prt_adoutlist_by_term

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

on b8w_prt_adoutlist_by_term.create
call super::create
end on

on b8w_prt_adoutlist_by_term.destroy
call super::destroy
end on

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 1 //세로2, 가로1
ib_margin = False

end event

event ue_ok;call super::ue_ok;//조회
String ls_where, ls_todt, ls_fromdt
date ld_todt, ld_fromdt
Long ll_row
boolean lb_check

ld_todt = dw_cond.object.movedt_to[1]
ld_fromdt = dw_cond.object.movedt_fr[1]
ls_todt = String(ld_todt, 'yyyymmdd')
ls_fromdt = String(ld_fromdt, 'yyyymmdd')

If IsNull(ls_todt) Then ls_todt = ""
If IsNull(ls_fromdt) Then ls_fromdt = ""

//ranger가 확정이 되면
If ls_fromdt <> ""  and ls_todt <> "" Then
	ll_row = fi_chk_frto_day(ld_fromdt, ld_todt)
	If ll_row < 0 Then
	 f_msg_usr_err(211, Title, "이동일자")             //입력 날짜 순저 잘 못 됨
	 dw_cond.SetFocus()
	 dw_cond.SetColumn("movedt_fr")
	 Return 
	End If 	
  If ls_where <> "" Then ls_where += " And "  
  ls_where += "to_char(dtl.movedt, 'YYYYMMDD') >='" + ls_fromdt + "' " + &
				"and to_char(dtl.movedt, 'YYYYMMDD') < = '" + ls_todt + "' "
			  
ElseIf ls_fromdt <> "" and ls_todt = "" Then			//시작 날짜만 있을때 
	If ls_where <> "" Then ls_where += "And "
	ls_where += "to_char(dtl.movedt,'YYYYMMDD') > = '" + ls_fromdt + "' "
ElseIf ls_fromdt = "" and ls_todt <> "" Then			//끝나는 날짜만 있을때   
	If ls_where <> "" Then ls_where += "And "
	ls_where += "to_char(dtl.movedt, 'YYYYMMDD') < = '" + ls_todt + "' " 
End If

If ls_fromdt <> ""  Then
	dw_list.object.fromdt_t.Text = String(ld_fromdt,'yyyy-mm-dd') 
End If

If ls_todt <> "" Then
	dw_list.object.todt_t.Text = String(ld_todt,'yyyy-mm-dd') 
End If

dw_list.is_where = ls_where
dw_list.GroupCalc()
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
	Name	: b8w_prt_adoutlist_by_term
	Desc.	: 일자별이동리스크
	Date	: 2002.10.31
	Ver.	: 1.0
	Programer : Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/
String ls_type, ls_desc

ls_type = fs_get_control("B5", "H200", ls_desc)


If ls_type = '0' Then
	dw_list.object.admodel_sale_amt.Format = "#,##0"
	dw_list.object.compute_1.Format = "#,##0"
	dw_list.object.compute_2.Format = "#,##0"	
ElseIf ls_type = '1' Then
	dw_list.object.admodel_sale_amt.Format = "#,##0.0"
	dw_list.object.compute_1.Format = "#,##0.0"
	dw_list.object.compute_2.Format = "#,##0.0"
ElseIf ls_type = '2' Then
	dw_list.object.admodel_sale_amt.Format = "#,##0.00"
	dw_list.object.compute_1.Format = "#,##0.00"
	dw_list.object.compute_2.Format = "#,##0.00"
Else
	dw_list.object.admodel_sale_amt.Format = "#,##0.0000"
	dw_list.object.compute_1.Format = "#,##0.0000"
	dw_list.object.compute_2.Format = "#,##0.0000"
End If
end event

type dw_cond from w_a_print`dw_cond within b8w_prt_adoutlist_by_term
integer x = 82
integer y = 80
integer width = 1262
integer height = 96
string dataobject = "b8dw_cnd_prt_adoutlist_by_term"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild ldc_partner
Long li_exist
String ls_filter

Choose Case dwo.name
	Case "levelcod"
		//LEVELCOD가 바뀜에 따라서 대리점 바뀐다...
		This.object.partner[row] = ''		//DDDW 구함				
		li_exist = this.GetChild("partner", ldc_partner)		//DDDW 구함
		If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 대리점")
	
		ls_filter = "levelcod = '" + data  + "'" 				
		ldc_partner.SetTransObject(SQLCA)
		li_exist =ldc_partner.Retrieve()
		ldc_partner.SetFilter(ls_filter)			//Filter정함
		ldc_partner.Filter()
		
		If li_exist < 0 Then 				
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return 1  		//선택 취소 focus는 그곳에
		End If  

End Choose	
end event

type p_ok from w_a_print`p_ok within b8w_prt_adoutlist_by_term
integer x = 1504
integer y = 40
end type

type p_close from w_a_print`p_close within b8w_prt_adoutlist_by_term
integer x = 1824
integer y = 40
end type

type dw_list from w_a_print`dw_list within b8w_prt_adoutlist_by_term
integer x = 23
integer y = 256
integer width = 3890
integer height = 1348
string dataobject = "b8dw_prt_adoutlist_by_term"
end type

type p_1 from w_a_print`p_1 within b8w_prt_adoutlist_by_term
end type

type p_2 from w_a_print`p_2 within b8w_prt_adoutlist_by_term
end type

type p_3 from w_a_print`p_3 within b8w_prt_adoutlist_by_term
end type

type p_5 from w_a_print`p_5 within b8w_prt_adoutlist_by_term
end type

type p_6 from w_a_print`p_6 within b8w_prt_adoutlist_by_term
end type

type p_7 from w_a_print`p_7 within b8w_prt_adoutlist_by_term
end type

type p_8 from w_a_print`p_8 within b8w_prt_adoutlist_by_term
end type

type p_9 from w_a_print`p_9 within b8w_prt_adoutlist_by_term
end type

type p_4 from w_a_print`p_4 within b8w_prt_adoutlist_by_term
end type

type gb_1 from w_a_print`gb_1 within b8w_prt_adoutlist_by_term
end type

type p_port from w_a_print`p_port within b8w_prt_adoutlist_by_term
end type

type p_land from w_a_print`p_land within b8w_prt_adoutlist_by_term
end type

type gb_cond from w_a_print`gb_cond within b8w_prt_adoutlist_by_term
integer x = 27
integer y = 8
integer width = 1358
integer height = 220
end type

type p_saveas from w_a_print`p_saveas within b8w_prt_adoutlist_by_term
end type

