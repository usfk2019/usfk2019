$PBExportHeader$b2w_prt_partner_reqdtl_list.srw
$PBExportComments$[chooys] 대리점미지급보고서 Window
forward
global type b2w_prt_partner_reqdtl_list from w_a_print
end type
end forward

global type b2w_prt_partner_reqdtl_list from w_a_print
integer width = 3273
end type
global b2w_prt_partner_reqdtl_list b2w_prt_partner_reqdtl_list

type variables
String is_levelcode
end variables

on b2w_prt_partner_reqdtl_list.create
call super::create
end on

on b2w_prt_partner_reqdtl_list.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;//조회
String ls_commdtfrom, ls_commdtto, ls_partner, ls_where
Long ll_row

String ls_code[], ls_desc
Int	li_cnt

ls_commdtfrom = String(dw_cond.object.commdtfrom[1], 'yyyymm')
ls_commdtto = String(dw_cond.object.commdtto[1], 'yyyymm')
ls_partner = Trim(dw_cond.object.partner[1])

If IsNull(ls_commdtfrom) Then ls_commdtfrom = ""
If IsNull(ls_commdtto) Then ls_commdtto = ""
If IsNull(ls_partner) Then ls_partner = ""

ls_where = ""

If ls_commdtfrom <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(commdt, 'yyyymm') >= '" + ls_commdtfrom + "' "
End If

If ls_commdtto <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(commdt, 'yyyymm') <= '" + ls_commdtto + "' "
End If

If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "req.partner = '" + ls_partner + "' "
End If


//대리점수수료, 대리점미수금, 대리점수수료지급 코드 가져오기
li_cnt = fi_cut_string(fs_get_control("A1","C300",ls_desc),";",ls_code)




dw_list.is_where = ls_where
//ll_row = dw_list.Retrieve()
ll_row = dw_list.Retrieve(ls_code[1],ls_code[2],ls_code[3],is_levelcode)
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If


end event

event ue_init();call super::ue_init;ii_orientation = 1 //가로인쇄
ib_margin = True
end event

event ue_saveas();call super::ue_saveas;ib_saveas = True
idw_saveas = dw_list
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within b2w_prt_partner_reqdtl_list
integer x = 37
integer width = 2400
integer height = 172
string dataobject = "b2dw_cnd_prt_partner_reqdtl_list"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::constructor;call super::constructor;String ls_desc

//대리점미지급관리대상(총판)Level code
is_levelcode = fs_get_control("A1","C100",ls_desc)

//is_levelcode에 해당하는 대리점만 선택
DataWindowChild ldc
String ls_filter
Long ll_row
ll_row = This.GetChild("partner", ldc)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
//MessageBox("is_levelcode", is_levelcode)
ls_filter = "levelcod = '" + is_levelcode + "' "
ldc.SetFilter(ls_filter)			//Filter정함
ldc.Filter()
ldc.SetTransObject(SQLCA)
ll_row =ldc.Retrieve() 
	
If ll_row < 0 Then 				//디비 오류 
	f_msg_usr_err(2100, Title, "Partner DDDW 오류")
	Return -2
End If
end event

type p_ok from w_a_print`p_ok within b2w_prt_partner_reqdtl_list
integer x = 2551
integer y = 44
end type

type p_close from w_a_print`p_close within b2w_prt_partner_reqdtl_list
integer x = 2853
integer y = 44
end type

type dw_list from w_a_print`dw_list within b2w_prt_partner_reqdtl_list
integer x = 23
integer y = 248
integer width = 3177
string dataobject = "b2dw_prt_partner_reqdtl_list"
end type

type p_1 from w_a_print`p_1 within b2w_prt_partner_reqdtl_list
integer y = 1580
end type

type p_2 from w_a_print`p_2 within b2w_prt_partner_reqdtl_list
integer y = 1580
end type

type p_3 from w_a_print`p_3 within b2w_prt_partner_reqdtl_list
integer y = 1580
end type

type p_5 from w_a_print`p_5 within b2w_prt_partner_reqdtl_list
integer y = 1580
end type

type p_6 from w_a_print`p_6 within b2w_prt_partner_reqdtl_list
integer y = 1580
end type

type p_7 from w_a_print`p_7 within b2w_prt_partner_reqdtl_list
integer y = 1580
end type

type p_8 from w_a_print`p_8 within b2w_prt_partner_reqdtl_list
integer y = 1580
end type

type p_9 from w_a_print`p_9 within b2w_prt_partner_reqdtl_list
integer y = 1580
end type

type p_4 from w_a_print`p_4 within b2w_prt_partner_reqdtl_list
end type

type gb_1 from w_a_print`gb_1 within b2w_prt_partner_reqdtl_list
integer y = 1540
end type

type p_port from w_a_print`p_port within b2w_prt_partner_reqdtl_list
integer y = 1604
end type

type p_land from w_a_print`p_land within b2w_prt_partner_reqdtl_list
integer y = 1616
end type

type gb_cond from w_a_print`gb_cond within b2w_prt_partner_reqdtl_list
integer x = 23
integer width = 2427
integer height = 236
end type

type p_saveas from w_a_print`p_saveas within b2w_prt_partner_reqdtl_list
integer y = 1580
end type

