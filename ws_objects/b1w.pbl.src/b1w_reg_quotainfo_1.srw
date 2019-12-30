$PBExportHeader$b1w_reg_quotainfo_1.srw
$PBExportComments$[ceusee] 장비 할부내역 등록1
forward
global type b1w_reg_quotainfo_1 from w_a_reg_m_m
end type
end forward

global type b1w_reg_quotainfo_1 from w_a_reg_m_m
integer width = 2199
integer height = 1240
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
end type
global b1w_reg_quotainfo_1 b1w_reg_quotainfo_1

type variables
Boolean ib_order
end variables

on b1w_reg_quotainfo_1.create
call super::create
end on

on b1w_reg_quotainfo_1.destroy
call super::destroy
end on

event ue_reset;call super::ue_reset;//초기화
dw_cond.ReSet()
dw_cond.InsertRow(0)
dw_cond.SetColumn("customerid")
Return 0 
end event

event ue_ok;call super::ue_ok;//조회
String ls_customerid, ls_orderno, ls_where
Long ll_row

ls_customerid = Trim(dw_cond.object.customerid[1])
ls_orderno = dw_cond.object.orderno[1]

If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_orderno) Then ls_orderno = ""

If ls_customerid = "" Then
	f_msg_info(200, Title, "고객번호")
	dw_cond.SetFocus()
	dw_cond.SetColumn("customerid")
	Return
End If

ls_where = ""
ls_where += "svc.customerid ='" + ls_customerid + "' "
If ls_orderno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(svc.orderno) = '" + ls_orderno + "' "
End If



dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If



end event

event open;call super::open;/*------------------------------------------------------------------------	
	Name	:	b1w_reg_quotainfo
	Desc	:	장비/할부 등록
	Ver.	: 	1.0
	Date	: 	2002.10.02
	Programer : choi bo ra(ceusee)
------------------------------------------------------------------------*/
ib_order = False
String ls_orderno
//iu_cust_msg.il_data[1] = il_orderno			//order number
//iu_cust_msg.is_data[1] = ls_customerid			//customer ID
f_center_window(b1w_reg_quotainfo_1)

//Setting
ib_order = False
ls_orderno = String(iu_cust_msg.il_data[1])
dw_cond.object.customerid[1] = iu_cust_msg.is_data[1]
dw_cond.object.orderno[1] = ls_orderno

If ls_orderno <> "" Then
	Trigger Event ue_ok() 
End If	
end event

event resize;//Size
dw_detail.Y = 23
dw_detail.X = 23
dw_detail.height = 856
dw_detail.width = 2126
p_close.X = 1920
p_close.Y = 924
end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_quotainfo_1
boolean visible = false
integer x = 448
integer y = 1444
integer width = 1705
integer height = 240
string dataobject = "b1dw_cnd_reg_quotainfo"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init;call super::ue_init;//Help Window
This.idwo_help_col[1] = This.Object.customerid
This.is_help_win[1] = "b1w_hlp_customerm"
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.customerid[row] = &
			 dw_cond.iu_cust_help.is_data[1]
			
		End If
End Choose

Return 0 
end event

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_quotainfo_1
boolean visible = false
integer x = 1856
integer y = 68
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_quotainfo_1
integer x = 1847
integer y = 916
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_quotainfo_1
boolean visible = false
integer x = 23
integer y = 888
integer width = 1527
integer height = 136
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_quotainfo_1
boolean visible = false
integer x = 0
integer y = 940
integer width = 2601
integer height = 476
string dataobject = "b1dw_cnd_quotainfo"
end type

event dw_master::ue_init;call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.svcorder_orderno_t
uf_init(ldwo_sort)
end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_quotainfo_1
integer x = 23
integer y = 24
integer width = 2126
string dataobject = "b1dw_reg_quotainfo_1"
end type

event dw_detail::ue_retrieve;call super::ue_retrieve;String ls_orderno, ls_status, ls_where, ls_check, ls_ref_desc
Long ll_row

ls_orderno = String(dw_master.object.svcorder_orderno[al_select_row])
ls_status = Trim(dw_master.object.svcorder_status[al_select_row]) 		//상태
ls_where = ""
If ls_orderno <> "" Then
	ls_where += "to_char(con.orderno) = '" + ls_orderno + "' "
End If

//개통신청 상태인지 확인 
ls_ref_desc = ""
ls_check = fs_get_control("B0", "P220", ls_ref_desc)
If ls_check = ls_status Then
	ib_order = True
Else
	ib_order = False
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -1
End If
Return 0
end event

event dw_detail::buttonclicked;//Button Click
String ls_orderno, ls_orderdt
Long ll_master_row
String ls_customerid, ls_itemcod, ls_itemnm, ls_priceplan

ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row < 0 Then Return 
ls_customerid = Trim(dw_master.object.svcorder_customerid[ll_master_row])
ls_priceplan = Trim(dw_master.object.svcorder_priceplan[ll_master_row])
ls_orderno	= String(dw_master.object.svcorder_orderno[ll_master_row])
ls_itemcod = Trim(dw_detail.object.contractdet_itemcod[row])
ls_itemnm = Trim(dw_detail.object.itemmst_itemnm[row])
ls_orderdt = Trim(dw_master.object.orderdt[ll_master_row])

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "장비/할부 정보"
iu_cust_msg.is_grp_name = "서비스 신청"
iu_cust_msg.is_data[5] = ls_orderno			//order number
iu_cust_msg.is_data[1] = ls_customerid			//customer ID
iu_cust_msg.is_data[2] = ls_itemcod				//item code
iu_cust_msg.is_data[3] = ls_itemnm				//item name
iu_cust_msg.is_data[4] = ls_priceplan	
iu_cust_msg.is_data[6] = "10102500"
iu_cust_msg.is_data[7] = ls_orderdt				//신청일자
iu_cust_msg.ib_data[1] = ib_order				//개통 여부	


OpenWithParm(b1w_reg_quotainfo_pop, iu_cust_msg)
end event

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_quotainfo_1
boolean visible = false
integer y = 1692
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_quotainfo_1
boolean visible = false
integer y = 1692
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_quotainfo_1
boolean visible = false
integer x = 69
integer y = 1696
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_quotainfo_1
boolean visible = false
integer x = 55
integer y = 1720
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_quotainfo_1
integer x = 0
integer y = 956
integer height = 40
end type

