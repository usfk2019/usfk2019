$PBExportHeader$c1w_prt_carrier_rate2.srw
$PBExportComments$[ceusee] 회선사업자 요울 레포트(합산)
forward
global type c1w_prt_carrier_rate2 from w_a_print
end type
end forward

global type c1w_prt_carrier_rate2 from w_a_print
end type
global c1w_prt_carrier_rate2 c1w_prt_carrier_rate2

type variables
String is_ratetype
end variables

on c1w_prt_carrier_rate2.create
call super::create
end on

on c1w_prt_carrier_rate2.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;//조회
String ls_cdsaup, ls_where, ls_opendt
Long ll_row

ls_cdsaup = Trim(dw_cond.object.cdsaup[1])
ls_opendt = String(dw_cond.object.opendt[1], 'yyyymmdd')

If IsNull(ls_cdsaup) Then ls_cdsaup = ""
If IsNull(ls_opendt) Then ls_opendt = ""

//필수 항목 Check
If ls_cdsaup = "" Then
	f_msg_info(200, Title,"Carrier")
	dw_cond.SetFocus()
	dw_cond.SetColumn("cdsaup")
   Return
End If

//retrieve
ls_where = ""
If ls_cdsaup <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "carrierid = '" + ls_cdsaup + "' "
End If	

If ls_opendt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	/*ls_where += "opendt IN (select Max(opendt) from carrier_rate where carrierid ='" + ls_cdsaup + "'" + &
	            " And to_char(opendt, 'yyyymmdd') <= '" + ls_opendt + "')" */
	ls_where += "to_char(opendt, 'yyyymmdd') <= '" + ls_opendt  + "' "
End If	

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, Title, "")	
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If



end event

event open;call super::open;String ls_ref_desc, ls_temp, ls_name[]

//회선사업자 type 코드
ls_ref_desc =""
ls_temp = fs_get_control("C1", "C120", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_name[])		
//회선사업자 type 코드(합산)
is_ratetype = ls_name[2]

DataWindowChild ldc_ratetype
Long li_exist
String ls_filter
Boolean lb_check


li_exist = dw_cond.GetChild("cdsaup", ldc_ratetype)		//DDDW 구함
If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : Carrier")
ls_filter = "ratetype = '" + is_ratetype + "'" 
ldc_ratetype.SetTransObject(SQLCA)
li_exist = ldc_ratetype.Retrieve()
ldc_ratetype.SetFilter(ls_filter)			//Filter정함
ldc_ratetype.Filter()

If li_exist < 0 Then 				
  f_msg_usr_err(2100, Title, "Retrieve()")
  Return 1  		//선택 취소 focus는 그곳에
End If  



end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 2 //세로2, 가로1
ib_margin = False
end event

type dw_cond from w_a_print`dw_cond within c1w_prt_carrier_rate2
integer width = 1152
string dataobject = "c1dw_cnd_reg_carrier_rate"
end type

type p_ok from w_a_print`p_ok within c1w_prt_carrier_rate2
integer x = 1321
integer y = 48
end type

type p_close from w_a_print`p_close within c1w_prt_carrier_rate2
integer x = 1627
integer y = 48
end type

type dw_list from w_a_print`dw_list within c1w_prt_carrier_rate2
string dataobject = "c1dw_prt_carrier_rate2"
end type

type p_1 from w_a_print`p_1 within c1w_prt_carrier_rate2
end type

type p_2 from w_a_print`p_2 within c1w_prt_carrier_rate2
end type

type p_3 from w_a_print`p_3 within c1w_prt_carrier_rate2
end type

type p_5 from w_a_print`p_5 within c1w_prt_carrier_rate2
end type

type p_6 from w_a_print`p_6 within c1w_prt_carrier_rate2
end type

type p_7 from w_a_print`p_7 within c1w_prt_carrier_rate2
end type

type p_8 from w_a_print`p_8 within c1w_prt_carrier_rate2
end type

type p_9 from w_a_print`p_9 within c1w_prt_carrier_rate2
end type

type p_4 from w_a_print`p_4 within c1w_prt_carrier_rate2
end type

type gb_1 from w_a_print`gb_1 within c1w_prt_carrier_rate2
end type

type p_port from w_a_print`p_port within c1w_prt_carrier_rate2
end type

type p_land from w_a_print`p_land within c1w_prt_carrier_rate2
end type

type gb_cond from w_a_print`gb_cond within c1w_prt_carrier_rate2
integer width = 1202
end type

type p_saveas from w_a_print`p_saveas within c1w_prt_carrier_rate2
end type

