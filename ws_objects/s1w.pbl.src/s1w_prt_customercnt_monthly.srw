$PBExportHeader$s1w_prt_customercnt_monthly.srw
$PBExportComments$[kem] 월별 가입고객현황
forward
global type s1w_prt_customercnt_monthly from w_a_print
end type
end forward

global type s1w_prt_customercnt_monthly from w_a_print
end type
global s1w_prt_customercnt_monthly s1w_prt_customercnt_monthly

on s1w_prt_customercnt_monthly.create
call super::create
end on

on s1w_prt_customercnt_monthly.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	s1w_prt_customercnt_monthly
	Desc.	: 	월별 가입고객현황 
	Ver.	:	1.0
	Date	:	2003.08.19
	Programer : Kim Eun Mi(kem)
--------------------------------------------------------------------------*/
String ls_ref_desc, ls_format
Date ld_sysdate

ld_sysdate = date(fdt_get_dbserver_now())

dw_cond.Object.start_month[1] = ld_sysdate
end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 2 //세로2, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;//조회
String ls_start_month, ls_svccod, ls_ctype1, ls_where, ls_date
Date   ld_date
Long ll_row

ld_date   = dw_cond.object.start_month[1]
ls_start_month = String(ld_date, 'yyyymm')
ls_svccod = Trim(dw_cond.object.svccod[1])
ls_ctype1 = Trim(dw_cond.object.ctype1[1])

If IsNull(ls_start_month) Then ls_start_month = ""

If ls_start_month = "" Then
	f_msg_info(200, title, "년월")
	dw_cond.SetFocus()
	dw_cond.SetColumn("start_month")
	Return
End If

If IsNull(ls_svccod) Then ls_svccod = '%'
If IsNull(ls_ctype1) Then ls_ctype1 = '%'
//ls_where = ""
//If ls_svccod <> "" Then
//	If ls_where <> "" Then ls_where += " And "
//    ls_where += " a.svccod = '" + ls_svccod + "' "
//End If
//
//If ls_ctype1 <> "" Then
//	If ls_where <> "" Then ls_where += " And "
//    ls_where += " a.ctype1 = '" + ls_ctype1 + "' "
//End If

//조건 Setting
dw_list.object.t_svccod.Text = dw_cond.object.compute_svccod[1]
dw_list.object.t_ctype1.Text = dw_cond.object.compute_ctype1[1]

dw_list.is_where = ls_where
ll_row	= dw_list.Retrieve(ld_date, ls_svccod, ls_ctype1)
If( ll_row = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_row < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If


end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_reset();call super::ue_reset;Date ld_sysdate

ld_sysdate = date(fdt_get_dbserver_now())

dw_cond.Object.start_month[1] = ld_sysdate
end event

type dw_cond from w_a_print`dw_cond within s1w_prt_customercnt_monthly
integer y = 40
integer height = 272
string dataobject = "s1dw_cnd_reg_customercnt_monthly"
end type

type p_ok from w_a_print`p_ok within s1w_prt_customercnt_monthly
end type

type p_close from w_a_print`p_close within s1w_prt_customercnt_monthly
end type

type dw_list from w_a_print`dw_list within s1w_prt_customercnt_monthly
string dataobject = "s1dw_prt_customercnt_monthly"
end type

event dw_list::retrieveend;call super::retrieveend;Long ll_row

dw_list.AcceptText()

If dw_list.RowCount() > 0 Then
	For ll_row = 1 TO dw_list.RowCount()
		dw_list.object.cnt_rate[ll_row] = dw_list.object.rate[ll_row]
	Next
End If
end event

type p_1 from w_a_print`p_1 within s1w_prt_customercnt_monthly
end type

type p_2 from w_a_print`p_2 within s1w_prt_customercnt_monthly
end type

type p_3 from w_a_print`p_3 within s1w_prt_customercnt_monthly
end type

type p_5 from w_a_print`p_5 within s1w_prt_customercnt_monthly
end type

type p_6 from w_a_print`p_6 within s1w_prt_customercnt_monthly
end type

type p_7 from w_a_print`p_7 within s1w_prt_customercnt_monthly
end type

type p_8 from w_a_print`p_8 within s1w_prt_customercnt_monthly
end type

type p_9 from w_a_print`p_9 within s1w_prt_customercnt_monthly
end type

type p_4 from w_a_print`p_4 within s1w_prt_customercnt_monthly
end type

type gb_1 from w_a_print`gb_1 within s1w_prt_customercnt_monthly
end type

type p_port from w_a_print`p_port within s1w_prt_customercnt_monthly
end type

type p_land from w_a_print`p_land within s1w_prt_customercnt_monthly
end type

type gb_cond from w_a_print`gb_cond within s1w_prt_customercnt_monthly
end type

type p_saveas from w_a_print`p_saveas within s1w_prt_customercnt_monthly
end type

