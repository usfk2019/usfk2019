$PBExportHeader$b1w_reg_quotainfo.srw
$PBExportComments$[ceusee] 장비침 할부내역 등록
forward
global type b1w_reg_quotainfo from w_a_reg_m_m
end type
end forward

global type b1w_reg_quotainfo from w_a_reg_m_m
integer width = 2738
integer height = 2020
end type
global b1w_reg_quotainfo b1w_reg_quotainfo

type variables
Boolean ib_order
String is_active
String is_reqactive

//추가 (개통(단말리미등록))
String is_reqactive_ad
end variables

forward prototypes
public function integer wfi_get_customerid (string as_customerid)
end prototypes

public function integer wfi_get_customerid (string as_customerid);/*------------------------------------------------------------------------
	Name	: wfi_get_customerid
	Desc	: 고객 Id 구하기
	Date	: 2002.10.01
	Arg.	: string as_customerid
	Retrun	: integer
	 			-1 : Error
	Ver.	: 1.0
	programer : Choi Bo Ra (ceusee)
------------------------------------------------------------------------*/
String ls_customernm
Select customernm
Into :ls_customernm
From customerm
Where customerid = :as_customerid;

If SQLCA.SQLCode = 100 Then		//Not Found
   dw_cond.object.customernm[1] = ""
   Return -1
End If

dw_cond.object.customernm[1] = ls_customernm
Return 0

end function

on b1w_reg_quotainfo.create
call super::create
end on

on b1w_reg_quotainfo.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;//조회
String ls_customerid, ls_orderno, ls_orderdtfrom, ls_orderdtto, ls_where
Long ll_row

ls_customerid = Trim(dw_cond.object.customerid[1])
ls_orderno = dw_cond.object.orderno[1]
ls_orderdtfrom = String(dw_cond.object.orderdtfrom[1], 'yyyymmdd')
ls_orderdtto = String(dw_cond.object.orderdtto[1], 'yyyymmdd')
If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_orderno) Then ls_orderno = ""
If IsNull(ls_orderdtfrom) Then ls_orderdtfrom = ""
If IsNull(ls_orderdtto) Then ls_orderdtto = ""

If ls_orderdtfrom <> "" And ls_orderdtto <> "" Then
	If ls_orderdtfrom  > ls_orderdtto Then
		f_msg_usr_err(201, title, "신청일")
		dw_cond.SetFocus()
		dw_cond.SetColumn("orderdtfrom")
		Return
	End If
End If


ls_where = ""
ls_where += "(svc.status = '" + is_active + "' or svc.status = '" + is_reqactive + "' or svc.status = '" + is_reqactive_ad + "') "
If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "svc.customerid ='" + ls_customerid + "' "
End If

If ls_orderno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(svc.orderno) = '" + ls_orderno + "' "
End If

If ls_orderdtfrom <> ""  and ls_orderdtto  <>  "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(svc.orderdt,'yyyymmdd') >= '" + ls_orderdtfrom + "' And " + &
					"to_char(svc.orderdt,'yyyymmdd') <= '" + ls_orderdtto + "' "

ElseIf ls_orderdtfrom <> "" and ls_orderdtto = "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(svc.orderdt,'yyyymmdd') >= '" + ls_orderdtfrom + "' "

ElseIf ls_orderdtfrom = "" and ls_orderdtto <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(svc.orderdt,'yyyymmdd') <= '" + ls_orderdtto + "' "

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
	Name	:	b1w_reg_quotainof
	Desc	:	장비/할부 등록
	Ver.	: 	1.0
	Date	: 	2002.10.02
	Programer : choi bo ra(ceusee)
------------------------------------------------------------------------*/
String ls_ref_desc
ib_order = False
is_active = ""
is_reqactive = ""


//개통신청 상태 코드
ls_ref_desc = ""
is_reqactive = fs_get_control("B0", "P220", ls_ref_desc)
is_active = fs_get_control("B0", "P223", ls_ref_desc)	
is_reqactive_ad = fs_get_control("B0","P241",ls_ref_desc)

	
end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_quotainfo
integer width = 1755
integer height = 276
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
			 dw_cond.Object.customernm[row] = &
			 dw_cond.iu_cust_help.is_data[2]
			
		End If
End Choose

Return 0 
end event

event dw_cond::itemchanged;if dwo.name = "customerid" Then
	wfi_get_customerid(data) 		//올바른 고객인지 확인
End If
end event

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_quotainfo
integer x = 1920
integer y = 48
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_quotainfo
integer x = 2226
integer y = 48
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_quotainfo
integer width = 1792
integer height = 340
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_quotainfo
integer x = 27
integer y = 360
integer width = 2629
integer height = 528
string dataobject = "b1dw_cnd_quotainfo"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.svcorder_orderno_t
uf_init(ldwo_sort,'D', RGB(0,0,128))
end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_quotainfo
integer x = 23
integer y = 928
integer width = 2638
integer height = 772
string dataobject = "b1dw_reg_quotainfo"
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
iu_cust_msg.is_pgm_name = "할부/임대 정보"
iu_cust_msg.is_grp_name = "서비스 신청"
iu_cust_msg.is_data[5] = ls_orderno			//order number
iu_cust_msg.is_data[1] = ls_customerid			//customer ID
iu_cust_msg.is_data[2] = ls_itemcod				//item code
iu_cust_msg.is_data[3] = ls_itemnm				//item name
iu_cust_msg.is_data[4] = ls_priceplan	
iu_cust_msg.is_data[6] = gs_pgm_id[gi_open_win_no]
iu_cust_msg.is_data[7] = ls_orderdt				//신청일자
iu_cust_msg.ib_data[1] = ib_order				//개통 여부	

OpenWithParm(b1w_reg_quotainfo_pop, iu_cust_msg)
end event

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_quotainfo
boolean visible = false
integer y = 1692
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_quotainfo
boolean visible = false
integer y = 1692
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_quotainfo
boolean visible = false
integer x = 69
integer y = 1696
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_quotainfo
integer x = 46
integer y = 1724
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_quotainfo
integer y = 892
end type

