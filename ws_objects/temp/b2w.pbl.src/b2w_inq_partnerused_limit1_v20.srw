$PBExportHeader$b2w_inq_partnerused_limit1_v20.srw
$PBExportComments$[ssong]대리점 사용한도조회
forward
global type b2w_inq_partnerused_limit1_v20 from w_a_inq_m_m
end type
end forward

global type b2w_inq_partnerused_limit1_v20 from w_a_inq_m_m
integer width = 3131
integer height = 1872
end type
global b2w_inq_partnerused_limit1_v20 b2w_inq_partnerused_limit1_v20

type variables
Boolean ib_new
String  is_receiptcod, is_limit_flag, is_level_code
end variables

on b2w_inq_partnerused_limit1_v20.create
call super::create
end on

on b2w_inq_partnerused_limit1_v20.destroy
call super::destroy
end on

event ue_ok;call super::ue_ok;String ls_partner, ls_where, ls_new
Long   ll_rows

ls_new = Trim(dw_cond.Object.new[1])

If ls_new = "Y" then	
	ib_new = True
Else 
	ib_new = False
End If

ls_partner = fs_snvl(dw_cond.Object.partner[1], '')

ls_where = ""

If (ls_partner <> "" ) then
	If(ls_where <> "" ) then ls_where += " AND "
	ls_where += "a.partner = '" + ls_partner + "'"
End If

IF ls_where <> "" THEN ls_where += " AND "
ls_where += "a.limit_flag = '" + is_limit_flag + "' "

dw_master.SetRedraw(False)

If ib_new Then
	dw_master.DataObject = "b2dw_mst_inq_partnerused_limit_2_v20"
	dw_master.SetTransObject(SQLCA)
	dw_master.is_where = ls_where
	
Else
	dw_master.DataObject = "b2dw_mst_inq_partnerused_limit_1_v20"
	dw_master.SetTransObject(SQLCA)
	dw_master.is_where = ls_where
End If

//Retrieve
ll_rows	= dw_master.Retrieve()
dw_master.SetRedraw(True)

If( ll_rows = 0 ) Then
	f_msg_info(1000, Title, "")
	TriggerEvent("ue_reset")
ElseIf( ll_rows < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If
end event

event open;call super::open;String ls_ref_desc

is_limit_flag = fs_get_control("A1", "C723", ls_ref_desc)

is_level_code = fs_get_control("A1", "C100", ls_ref_desc)

end event

type dw_cond from w_a_inq_m_m`dw_cond within b2w_inq_partnerused_limit1_v20
integer width = 1984
integer height = 128
string dataobject = "b2dw_cnd_inq_partnerused_limit"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type p_ok from w_a_inq_m_m`p_ok within b2w_inq_partnerused_limit1_v20
integer x = 2235
end type

type p_close from w_a_inq_m_m`p_close within b2w_inq_partnerused_limit1_v20
integer x = 2546
end type

type gb_cond from w_a_inq_m_m`gb_cond within b2w_inq_partnerused_limit1_v20
integer width = 2048
integer height = 212
end type

type dw_master from w_a_inq_m_m`dw_master within b2w_inq_partnerused_limit1_v20
integer y = 244
integer height = 512
string dataobject = "b2dw_mst_inq_partnerused_limit_1_v20"
end type

event dw_master::clicked;call super::clicked;String ls_type

ls_type = dwo.Type

Choose Case UPPER(ls_type)
	Case "COLUMN"
		   return 1
	Case "ROW"
			return 1		
End Choose
end event

event dw_master::retrieveend;call super::retrieveend;
dwObject ldwo_sort

ib_sort_use = True
ldwo_sort = Object.partner_t
uf_init( ldwo_sort , "A", RGB(0,0,128))

dw_cond.enabled = True
end event

event dw_master::ue_init;call super::ue_init;
dwObject ldwo_sort

ib_sort_use = True
ldwo_sort = Object.partner_t
uf_init( ldwo_sort , "A", RGB(0,0,128))

end event

type dw_detail from w_a_inq_m_m`dw_detail within b2w_inq_partnerused_limit1_v20
integer x = 32
integer y = 800
integer height = 924
string dataobject = "b2dw_det_inq_partnerused_limit_1_v20"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event dw_detail::ue_retrieve;call super::ue_retrieve;String	ls_where
Long		ll_rows
String	ls_partner, ls_prefixno, ls_priceplan


ls_partner = Trim(dw_master.Object.partner[al_select_row])
ls_prefixno = Trim(dw_master.Object.partnermst_prefixno[al_select_row])


//detail by master
If dw_master.DataObject = "b2dw_mst_inq_partnerused_limit_1_v20" Then
	dw_detail.DataObject = "b2dw_det_inq_partnerused_limit_1_v20"
	dw_detail.SetTransObject(SQLCA)
	dw_detail.is_where = ls_where
	
Else
	dw_detail.DataObject = "b2dw_det_inq_partnerused_limit_2_v20"
	dw_detail.SetTransObject(SQLCA)
	dw_detail.is_where = ls_where
	
End If


//Retrieve
If al_select_row > 0 Then
	If dw_master.DataObject = "b2dw_mst_inq_partnerused_limit_2_v20" then
		ls_priceplan = Trim(dw_master.Object.partnerused_limit_priceplan[al_select_row])	
	 //ls_where = "substr(a.partner_prefixno,1,to_number(substr('" + is_level_code +"',1,1))*3) = '"+ ls_prefixno +"' AND a.priceplan = '"+ ls_priceplan + "' AND a.limit_flag = '"+ is_limit_flag + "'"
		ls_where += "a.partner_prefixno LIKE '" + ls_prefixno + "%'AND a.priceplan = '"+ ls_priceplan + "' AND a.limit_flag = '"+ is_limit_flag + "'"
		//ls_where	+= "partnermst.partnernm LIKE '%"+ ls_partnernm +"%'"
	//ls_where = "mv_partner= '" + ls_partner + "' "
		
  Else
	//ls_where = "substr(a.partner_prefixno,1,to_number(substr('" + is_level_code +"',1,1))*3) = '"+ ls_prefixno +"' AND a.limit_flag = '"+ is_limit_flag + "'"
	ls_where += "a.partner_prefixno LIKE '" + ls_prefixno + "%'AND  a.limit_flag = '"+ is_limit_flag + "'"
  End If
	dw_detail.is_where = ls_where		
	ll_rows = dw_detail.Retrieve()	
	If ll_rows < 0 Then
		f_msg_usr_err(2100, Parent.Title, "Retrieve()")
		Return -1
	ElseIf ll_rows = 0 Then
		//Return 1
	End If
End if

Return 0
end event

type st_horizontal from w_a_inq_m_m`st_horizontal within b2w_inq_partnerused_limit1_v20
integer x = 32
integer y = 764
end type

