$PBExportHeader$c1w_prt_carrier_amount_daily_bef.srw
$PBExportComments$[ssong] 회선정산료레포트(합산)
forward
global type c1w_prt_carrier_amount_daily_bef from w_a_print
end type
end forward

global type c1w_prt_carrier_amount_daily_bef from w_a_print
end type
global c1w_prt_carrier_amount_daily_bef c1w_prt_carrier_amount_daily_bef

type variables
String is_ratetype
end variables

on c1w_prt_carrier_amount_daily_bef.create
call super::create
end on

on c1w_prt_carrier_amount_daily_bef.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	c1w_prt_carrier_amount_daily
	Desc.	: 	회선정산료레포트(합산)- 일자별합산
	Ver.	:	1.0
	Date	:	2005.11.01
	Programer : Song Eun Mi
--------------------------------------------------------------------------*/
String ls_ref_desc, ls_temp, ls_name[]

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

event ue_init();call super::ue_init;ii_orientation = 2
ib_margin = False
end event

event ue_ok();call super::ue_ok;
String ls_cdsaup, ls_dtfrom, ls_dtto, ls_nmsaup, ls_where, ls_zoncod, ls_zonegroup
String ls_compute_zoncod, ls_compute_zonegroup
long ll_row

ls_cdsaup = Trim(dw_cond.Object.cdsaup[1])
ls_dtfrom = String(dw_cond.Object.dtfrom[1],"yyyymmdd")
ls_dtto   = String(dw_cond.Object.dtto[1],"yyyymmdd")
ls_zoncod = Trim(dw_cond.Object.zoncod[1])
ls_zonegroup = Trim(dw_cond.Object.zonegroup[1])

If IsNull(ls_cdsaup) Then ls_cdsaup = ""
If IsNull(ls_zoncod) Then ls_zoncod = ""
If IsNull(ls_zonegroup) Then ls_zonegroup = ""

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

If ls_cdsaup <> "" Then
	select carriernm into :ls_nmsaup
	from carrier_mst
	where carrierid = :ls_cdsaup;
Else
	ls_nmsaup = 'ALL'
End If
 
ls_where = ""
 
If ls_cdsaup <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "amount.carrierid = '" + ls_cdsaup + "' "	
End If
 
If ls_dtfrom <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(amount.workdt,'yyyymmdd') >= '" + ls_dtfrom + "' "	
End If
 
If ls_dtto <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(amount.workdt,'yyyymmdd') <= '" + ls_dtto + "' "	
End If

If ls_zoncod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "rate2.zoncod = '" + ls_zoncod + "' "
End If

If ls_zonegroup <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "rate2.zonegroup = '" + ls_zonegroup + "' "	
End If
	

dw_list.is_where = ls_where

dw_list.Object.t_saup.text = ls_nmsaup
dw_list.Object.t_dtfrom.text = MidA(ls_dtfrom,1,4) + "-" + MidA(ls_dtfrom,5,2) + "-" + MidA(ls_dtfrom,7,2) 
dw_list.Object.t_dtto.text = MidA(ls_dtto,1,4) + "-" + MidA(ls_dtto,5,2) + "-" + MidA(ls_dtto,7,2)

ls_compute_zoncod = Trim(dw_cond.Object.compute_zoncod[1])
If IsNull(ls_compute_zoncod) Or ls_compute_zoncod = "" Then ls_compute_zoncod = "ALL"
dw_list.Object.t_zoncod.text = ls_compute_zoncod

ls_compute_zonegroup = Trim(dw_cond.Object.compute_zonegroup[1])
If IsNull(ls_compute_zonegroup) Or ls_compute_zonegroup = "" Then ls_compute_zonegroup = "ALL"
dw_list.Object.t_zonegroup.text = ls_compute_zonegroup

ll_row	= dw_list.Retrieve()
If ( ll_row = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf ( ll_row < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within c1w_prt_carrier_amount_daily_bef
integer y = 40
integer width = 1102
integer height = 332
string dataobject = "c1dw_cnd_reg_carrier_amount_daily"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within c1w_prt_carrier_amount_daily_bef
integer x = 1298
integer y = 140
end type

type p_close from w_a_print`p_close within c1w_prt_carrier_amount_daily_bef
integer x = 1600
integer y = 140
end type

type dw_list from w_a_print`dw_list within c1w_prt_carrier_amount_daily_bef
integer y = 396
integer height = 1216
string dataobject = "c1dw_prt_reg_carrier_amount_daily_bef"
end type

type p_1 from w_a_print`p_1 within c1w_prt_carrier_amount_daily_bef
end type

type p_2 from w_a_print`p_2 within c1w_prt_carrier_amount_daily_bef
end type

type p_3 from w_a_print`p_3 within c1w_prt_carrier_amount_daily_bef
end type

type p_5 from w_a_print`p_5 within c1w_prt_carrier_amount_daily_bef
end type

type p_6 from w_a_print`p_6 within c1w_prt_carrier_amount_daily_bef
end type

type p_7 from w_a_print`p_7 within c1w_prt_carrier_amount_daily_bef
end type

type p_8 from w_a_print`p_8 within c1w_prt_carrier_amount_daily_bef
end type

type p_9 from w_a_print`p_9 within c1w_prt_carrier_amount_daily_bef
end type

type p_4 from w_a_print`p_4 within c1w_prt_carrier_amount_daily_bef
end type

type gb_1 from w_a_print`gb_1 within c1w_prt_carrier_amount_daily_bef
end type

type p_port from w_a_print`p_port within c1w_prt_carrier_amount_daily_bef
end type

type p_land from w_a_print`p_land within c1w_prt_carrier_amount_daily_bef
end type

type gb_cond from w_a_print`gb_cond within c1w_prt_carrier_amount_daily_bef
integer width = 1202
integer height = 388
end type

type p_saveas from w_a_print`p_saveas within c1w_prt_carrier_amount_daily_bef
end type

