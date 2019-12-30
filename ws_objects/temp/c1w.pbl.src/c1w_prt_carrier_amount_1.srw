$PBExportHeader$c1w_prt_carrier_amount_1.srw
$PBExportComments$[ceusee] 건당 정산료 선/후불 구분
forward
global type c1w_prt_carrier_amount_1 from w_a_print
end type
end forward

global type c1w_prt_carrier_amount_1 from w_a_print
end type
global c1w_prt_carrier_amount_1 c1w_prt_carrier_amount_1

type variables
String is_ratetype, is_flag
end variables

on c1w_prt_carrier_amount_1.create
call super::create
end on

on c1w_prt_carrier_amount_1.destroy
call super::destroy
end on

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 2 //세로2, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;String ls_cdsaup, ls_dtfrom, ls_dtto, ls_nmsaup, ls_where, ls_check
long ll_row

ls_cdsaup = Trim(dw_cond.Object.cdsaup[1])
ls_dtfrom = String(dw_cond.Object.dtfrom[1],"yyyymmdd")
ls_dtto   = String(dw_cond.Object.dtto[1],"yyyymmdd")
ls_check = Trim(dw_cond.object.check[1])

If isnull(dw_cond.Object.cdsaup[1]) then 
	f_msg_usr_err(200, Title, "회선사업자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("cdsaup")	
	return 
End If	

If isnull(ls_dtfrom) Or ls_dtfrom = "" then
	f_msg_usr_err(200, Title, "기간 From")
	dw_cond.SetFocus()
	dw_cond.SetColumn("dtfrom")	
	return 
End If	

If isnull(ls_dtto) Or ls_dtto = "" then  
	f_msg_usr_err(200, Title, "기간 To")
	dw_cond.SetFocus()
	dw_cond.SetColumn("dtto")	
	return 
End If	

If ls_dtfrom > ls_dtto Then
	f_msg_usr_err(201, title, "기간")
	dw_cond.SetFocus()
	dw_cond.SetColumn("dtto")	
	return 
End If	

 select carriernm into :ls_nmsaup
 from carrier_mst
 where carrierid = :ls_cdsaup;
 
 ls_where = ""
 
 If ls_cdsaup <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "carr.carrierid = '" + ls_cdsaup + "' "	
 End If
 
 If ls_dtfrom <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(carr.workdt,'yyyymmdd') >= '" + ls_dtfrom + "' "	
 End If
 
 If ls_dtto <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(carr.workdt,'yyyymmdd') <= '" + ls_dtto + "' "	
 End If
 
 If ls_check <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "carr.cdr_type = '" + ls_check + "' "	
 End If
 
 dw_list.Object.t_saup.text = ls_nmsaup
 dw_list.Object.t_dtfrom.text = MidA(ls_dtfrom,1,4) + "-" + MidA(ls_dtfrom,5,2) + "-" + MidA(ls_dtfrom,7,2) 
 dw_list.Object.t_dtto.text = MidA(ls_dtto,1,4) + "-" + MidA(ls_dtto,5,2) + "-" + MidA(ls_dtto,7,2) 
 
  dw_list.is_where = ls_where
 ll_row	= dw_list.Retrieve(is_flag)
 If( ll_row = 0 ) Then
	f_msg_info(1000, Title, "")
 ElseIf( ll_row < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
 End If
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list

end event

event open;call super::open;String ls_ref_desc, ls_temp, ls_name[], ls_flag[]

//회선사업자 type 코드
ls_ref_desc =""
ls_temp = fs_get_control("C1", "C120", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_name[])		
//회선사업자 type 코드(건당)
is_ratetype = ls_name[1]

//biltime 분 FLag( D:버림,U;올림,O:반올림)
ls_ref_desc =""
ls_temp = fs_get_control("A1", "C600", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_flag[])
//회선사업자 type 코드(건당)
is_flag = ls_flag[1]

DataWindowChild ldc_ratetype
Long li_exist
String ls_filter
Boolean lb_check


li_exist = dw_cond.GetChild("cdsaup", ldc_ratetype)		//DDDW 구함
If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 회선사업자")
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

type dw_cond from w_a_print`dw_cond within c1w_prt_carrier_amount_1
integer x = 55
integer y = 40
integer width = 1307
integer height = 316
string dataobject = "c1w_cnd_reg_carrier_amount_1"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within c1w_prt_carrier_amount_1
integer x = 1499
integer y = 64
end type

type p_close from w_a_print`p_close within c1w_prt_carrier_amount_1
integer x = 1815
integer y = 64
end type

type dw_list from w_a_print`dw_list within c1w_prt_carrier_amount_1
integer y = 396
integer height = 1240
string dataobject = "c1dw_prt_reg_carrier_amount_1"
end type

type p_1 from w_a_print`p_1 within c1w_prt_carrier_amount_1
end type

type p_2 from w_a_print`p_2 within c1w_prt_carrier_amount_1
end type

type p_3 from w_a_print`p_3 within c1w_prt_carrier_amount_1
end type

type p_5 from w_a_print`p_5 within c1w_prt_carrier_amount_1
end type

type p_6 from w_a_print`p_6 within c1w_prt_carrier_amount_1
end type

type p_7 from w_a_print`p_7 within c1w_prt_carrier_amount_1
end type

type p_8 from w_a_print`p_8 within c1w_prt_carrier_amount_1
end type

type p_9 from w_a_print`p_9 within c1w_prt_carrier_amount_1
end type

type p_4 from w_a_print`p_4 within c1w_prt_carrier_amount_1
end type

type gb_1 from w_a_print`gb_1 within c1w_prt_carrier_amount_1
end type

type p_port from w_a_print`p_port within c1w_prt_carrier_amount_1
end type

type p_land from w_a_print`p_land within c1w_prt_carrier_amount_1
end type

type gb_cond from w_a_print`gb_cond within c1w_prt_carrier_amount_1
integer width = 1367
integer height = 380
end type

type p_saveas from w_a_print`p_saveas within c1w_prt_carrier_amount_1
end type

