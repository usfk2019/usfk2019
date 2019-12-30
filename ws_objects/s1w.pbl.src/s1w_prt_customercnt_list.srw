$PBExportHeader$s1w_prt_customercnt_list.srw
$PBExportComments$[y.k.min] 고객유치실적현황
forward
global type s1w_prt_customercnt_list from w_a_print
end type
end forward

global type s1w_prt_customercnt_list from w_a_print
integer width = 3131
integer height = 1952
end type
global s1w_prt_customercnt_list s1w_prt_customercnt_list

on s1w_prt_customercnt_list.create
call super::create
end on

on s1w_prt_customercnt_list.destroy
call super::destroy
end on

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 1 //세로0, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;//조회
String ls_yyyy, ls_work_type, ls_where
Long ll_row

ls_yyyy = String(dw_cond.object.yyyy[1], 'yyyy')
ls_work_type = Trim(dw_cond.object.work_type[1])

If IsNull(ls_yyyy) Then ls_yyyy = ""
If IsNull(ls_work_type) Then ls_work_type = ""

If ls_yyyy = "" Then
	f_msg_info(200, title, "년도")
	dw_cond.SetFocus()
	dw_cond.SetColumn("yyyy")
	Return
End If

dw_list.SetRedraw(False)
IF ls_work_type = "1" THEN			// 서비스별
	dw_list.DataObject = "s1dw_prt_customercnt_list_svc"

ElSEIF ls_work_type = "2" THEN	// 유치처별
	dw_list.DataObject = "s1dw_prt_customercnt_list_reg"

ElSEIF ls_work_type = "3" THEN	//지역별
	dw_list.DataObject = "s1dw_prt_customercnt_list_location"

ElSEIF ls_work_type = "4" THEN	// 고객유형별
	dw_list.DataObject = "s1dw_prt_customercnt_list_ctype"

ElSEIF ls_work_type = "5" THEN	// 담당자별
	dw_list.DataObject = "s1dw_prt_customercnt_list_macod"

END IF

dw_list.SetTransObject(SQLCA)
dw_list.SetRedraw(True)
ll_row = dw_list.Retrieve(ls_yyyy)

//년도 표시
dw_list.object.t_yyyy.Text = String(dw_cond.object.yyyy[1], 'yyyy')

If( ll_row = 0 ) Then
		f_msg_info(1000, Title, "")
	ElseIf( ll_row < 0 ) Then
		f_msg_usr_err(2100, Title, "Retrieve()")
	End If
end event

event open;call super::open;dw_cond.object.yyyy[1] = Date(fdt_get_dbserver_now())
end event

event ue_reset();call super::ue_reset;dw_cond.object.yyyy[1] = Date(fdt_get_dbserver_now())
end event

type dw_cond from w_a_print`dw_cond within s1w_prt_customercnt_list
integer x = 82
integer y = 52
integer width = 1678
integer height = 152
string dataobject = "s1dw_cnd_prt_customercnt_list"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within s1w_prt_customercnt_list
integer x = 1943
end type

type p_close from w_a_print`p_close within s1w_prt_customercnt_list
integer x = 2245
end type

type dw_list from w_a_print`dw_list within s1w_prt_customercnt_list
integer y = 284
integer height = 1336
string dataobject = "s1dw_prt_customercnt_list_svc"
end type

type p_1 from w_a_print`p_1 within s1w_prt_customercnt_list
end type

type p_2 from w_a_print`p_2 within s1w_prt_customercnt_list
end type

type p_3 from w_a_print`p_3 within s1w_prt_customercnt_list
end type

type p_5 from w_a_print`p_5 within s1w_prt_customercnt_list
end type

type p_6 from w_a_print`p_6 within s1w_prt_customercnt_list
end type

type p_7 from w_a_print`p_7 within s1w_prt_customercnt_list
end type

type p_8 from w_a_print`p_8 within s1w_prt_customercnt_list
end type

type p_9 from w_a_print`p_9 within s1w_prt_customercnt_list
end type

type p_4 from w_a_print`p_4 within s1w_prt_customercnt_list
end type

type gb_1 from w_a_print`gb_1 within s1w_prt_customercnt_list
end type

type p_port from w_a_print`p_port within s1w_prt_customercnt_list
end type

type p_land from w_a_print`p_land within s1w_prt_customercnt_list
end type

type gb_cond from w_a_print`gb_cond within s1w_prt_customercnt_list
integer width = 1806
integer height = 240
end type

type p_saveas from w_a_print`p_saveas within s1w_prt_customercnt_list
end type

