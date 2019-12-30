$PBExportHeader$s2w_prt_voice_tong2_inout_id.srw
$PBExportComments$[uhmjj] inid, outid 별 통화 통계보고서
forward
global type s2w_prt_voice_tong2_inout_id from w_a_print
end type
end forward

global type s2w_prt_voice_tong2_inout_id from w_a_print
integer height = 1956
end type
global s2w_prt_voice_tong2_inout_id s2w_prt_voice_tong2_inout_id

on s2w_prt_voice_tong2_inout_id.create
call super::create
end on

on s2w_prt_voice_tong2_inout_id.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_use_fr, ls_use_to, ls_area, ls_country, ls_priceplan, ls_out_id, ls_in_id, ls_sacno
String ls_where, ls_date, ls_dis_currency
Long   ll_row

ls_use_fr    = String(dw_cond.object.use_fr[1], 'yyyymmdd')
ls_use_to    = String(dw_cond.object.use_to[1], 'yyyymmdd')
ls_country	 = Trim(dw_cond.object.country[1])
ls_area  	 = Trim(dw_cond.object.area[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_out_id    = Trim(dw_cond.object.out_id[1])
ls_in_id    = Trim(dw_cond.object.in_id[1])
ls_sacno    = Trim(dw_cond.object.sacno[1])

If IsNull(ls_use_fr) Then ls_use_fr = ""
If IsNull(ls_use_to) Then ls_use_to = ""
If IsNull(ls_country) Then ls_country = ""
If IsNull(ls_area) Then ls_area = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_out_id) Then ls_out_id = ""
If IsNull(ls_in_id) Then ls_in_id = ""
If IsNull(ls_sacno) Then ls_sacno = ""

If ls_use_fr = "" Then 
	f_msg_info(200, title, "통화일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("use_fr")
	Return
End If

If ls_use_to = "" Then 
	f_msg_info(200, title, "통화일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("use_to")
	Return
End If

If ls_use_fr <> "" And ls_use_to <> "" Then
	If ls_use_fr > ls_use_to Then
		f_msg_usr_err(210, title, "통화일자")
		dw_cond.SetFocus()
		dw_cond.SetColumn("use_fr")
		Return
	End If
End If

If ls_use_fr <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "workdt  >= '" + ls_use_fr + "' "
	ls_date = MidA(ls_use_fr,1,4) + "-" +  MidA(ls_use_fr, 5,2)+ "-" +  MidA(ls_use_fr, 7,2) + " ~~ "
End If

If ls_use_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "workdt <= '" + ls_use_to + "' "
	ls_date += MidA(ls_use_to,1,4) + "-" +  MidA(ls_use_to, 5,2)+ "-" +  MidA(ls_use_to, 7,2)
End If

If ls_country <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "countrycod = '" + ls_country + "' "
End If

If ls_area <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "areacod = '" + ls_area + "' "
End If

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "priceplan = '" + ls_priceplan + "' "
End If

If ls_out_id <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "outid like '" + ls_out_id + '%' + "' "
End If

If ls_in_id <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "inid like '" + ls_in_id + '%' + "' "
End If

If ls_sacno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "sacnum = '" + ls_sacno + "' "
End If

//조건 Setting
If ls_date = "" Then ls_date = "All"
dw_list.object.t_date.Text = ls_date

SetPointer(HourGlass!)
dw_list.SetRedraw(False)

dw_list.is_where = ls_where
ll_row	= dw_list.Retrieve()

If( ll_row = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_row < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	dw_list.SetRedraw(True)
	Return 
End If

dw_list.SetRedraw(True)
SetPointer(Arrow!)




end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 2 //세로2, 가로1
ib_margin = False
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	s2w_prt_country_are
	Desc.	: 	국가 지역별 통계 보고서
	Ver.	:	1.0
	Date	:	2004.10.26
	Programer : UHM JAE JUN (uhmjj)
--------------------------------------------------------------------------*/

end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within s2w_prt_voice_tong2_inout_id
integer height = 276
string dataobject = "s2dw_cnd_reg_voice_tong2_inout_id"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within s2w_prt_voice_tong2_inout_id
integer x = 2414
end type

type p_close from w_a_print`p_close within s2w_prt_voice_tong2_inout_id
integer x = 2711
end type

type dw_list from w_a_print`dw_list within s2w_prt_voice_tong2_inout_id
integer y = 352
integer height = 1248
string dataobject = "s2dw_prt_voice_tong2_inout_id"
end type

type p_1 from w_a_print`p_1 within s2w_prt_voice_tong2_inout_id
integer y = 1648
end type

type p_2 from w_a_print`p_2 within s2w_prt_voice_tong2_inout_id
integer y = 1648
end type

type p_3 from w_a_print`p_3 within s2w_prt_voice_tong2_inout_id
integer y = 1648
end type

type p_5 from w_a_print`p_5 within s2w_prt_voice_tong2_inout_id
integer y = 1648
end type

type p_6 from w_a_print`p_6 within s2w_prt_voice_tong2_inout_id
integer y = 1648
end type

type p_7 from w_a_print`p_7 within s2w_prt_voice_tong2_inout_id
integer y = 1648
end type

type p_8 from w_a_print`p_8 within s2w_prt_voice_tong2_inout_id
integer y = 1648
end type

type p_9 from w_a_print`p_9 within s2w_prt_voice_tong2_inout_id
integer y = 1648
end type

type p_4 from w_a_print`p_4 within s2w_prt_voice_tong2_inout_id
end type

type gb_1 from w_a_print`gb_1 within s2w_prt_voice_tong2_inout_id
integer y = 1608
end type

type p_port from w_a_print`p_port within s2w_prt_voice_tong2_inout_id
integer y = 1672
end type

type p_land from w_a_print`p_land within s2w_prt_voice_tong2_inout_id
integer y = 1684
end type

type gb_cond from w_a_print`gb_cond within s2w_prt_voice_tong2_inout_id
integer width = 2286
integer height = 336
end type

type p_saveas from w_a_print`p_saveas within s2w_prt_voice_tong2_inout_id
integer y = 1648
end type

