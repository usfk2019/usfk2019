$PBExportHeader$b1w_inq_validkeystock.srw
$PBExportComments$[ssong] 대리점 인증 key 재고현황 - Window
forward
global type b1w_inq_validkeystock from w_a_inq_m_m
end type
type p_1 from u_p_reset within b1w_inq_validkeystock
end type
end forward

global type b1w_inq_validkeystock from w_a_inq_m_m
integer width = 3598
integer height = 2008
event ue_reset ( )
p_1 p_1
end type
global b1w_inq_validkeystock b1w_inq_validkeystock

type variables
Boolean ib_new
String  is_receiptcod
end variables

event ue_reset();dw_cond.reset()
dw_cond.insertrow(1)

dw_master.reset()


dw_detail.reset()
end event

on b1w_inq_validkeystock.create
int iCurrent
call super::create
this.p_1=create p_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
end on

on b1w_inq_validkeystock.destroy
call super::destroy
destroy(this.p_1)
end on

event ue_ok();call super::ue_ok;
String	ls_where
String	ls_levelcod, ls_new, ls_validkeytype
Long		ll_rows

ls_new = Trim(dw_cond.object.new[1])
If ls_new = "Y" Then 
	ib_new = True
Else
	ib_new = False
End If

ls_levelcod	= Trim(dw_cond.Object.levelcod[1])

ls_validkeytype = Trim(dw_cond.Object.validkey_type[1])

If( IsNull(ls_levelcod) ) Then ls_levelcod = ""

If( IsNull(ls_validkeytype)) Then ls_validkeytype = ""


//Dynamic SQL
ls_where = ""

If( ls_levelcod <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "b.partner = '"+ ls_levelcod +"'"
End If

If( ls_validkeytype <> "" ) Then
	If( ls_where <> "") Then ls_where += " AND "
	ls_where += "a.validkey_type = '"+ ls_validkeytype + "' "
End If

//
//If( ls_termdtto <> "" ) Then
//	If( ls_where <> "" ) Then ls_where += " AND "
//	ls_where += "to_char(penaltydet.termdt, 'YYYYMMDD') <= '"+ ls_termdtto +"'"
//End If
//
dw_master.SetRedraw(False)

If ib_new Then
	dw_master.DataObject = "b1dw_master_inq_validkeystock_1"
	dw_master.SetTransObject(SQLCA)
	dw_master.is_where = ls_where
	
Else
	dw_master.DataObject = "b1dw_master_inq_validkeystock_2"
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

event open;call super::open;String ls_ref_desc, ls_temp, ls_name[]

ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("B1", "P400", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", ls_name[])
is_receiptcod = ls_name[2]
end event

type dw_cond from w_a_inq_m_m`dw_cond within b1w_inq_validkeystock
integer x = 55
integer y = 52
integer width = 2501
integer height = 124
string dataobject = "b1dw_cnd_inq_validkeystock"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::ue_init();call super::ue_init;//idwo_help_col[1] = Object.customerid
//is_help_win[1] = "b1w_hlp_customerm"
//is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;//Choose Case dwo.Name
//	Case "customerid"
//		If iu_cust_help.ib_data[1] Then
//			Object.customerid[row] = iu_cust_help.is_data[1]
//			Object.customernm[row] = iu_cust_help.is_data[2]
//		End If
//		
//End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;//Choose Case Dwo.Name
//	Case "customerid"
//		Object.customernm[1] = ""
//		
//End Choose
end event

type p_ok from w_a_inq_m_m`p_ok within b1w_inq_validkeystock
integer x = 2638
end type

type p_close from w_a_inq_m_m`p_close within b1w_inq_validkeystock
integer x = 3232
boolean originalsize = false
end type

type gb_cond from w_a_inq_m_m`gb_cond within b1w_inq_validkeystock
integer x = 18
integer y = 8
integer width = 2551
integer height = 200
end type

type dw_master from w_a_inq_m_m`dw_master within b1w_inq_validkeystock
integer x = 23
integer y = 244
integer width = 3511
integer height = 644
string dataobject = "b1dw_master_inq_validkeystock_2"
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

event dw_master::ue_init();call super::ue_init;dwObject ldwo_sort

ib_sort_use = True
ldwo_sort = Object.partnermst_partner_t
uf_init( ldwo_sort , "A", RGB(0,0,128))

//dwObject ldwo_SORT
//
//ib_sort_use = True
//ldwo_SORT = Object.partner_t
//uf_init(ldwo_SORT)
end event

event dw_master::retrieveend;call super::retrieveend;dwObject ldwo_sort

ib_sort_use = True
ldwo_sort = Object.partnermst_partner_t
uf_init( ldwo_sort , "A", RGB(0,0,128))
end event

type dw_detail from w_a_inq_m_m`dw_detail within b1w_inq_validkeystock
integer x = 23
integer y = 920
integer width = 3511
integer height = 952
string dataobject = "b1dw_det_inq_validkeystock"
end type

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;String	ls_where
Long		ll_rows
String	ls_partner, ls_prefixno, ls_priceplan, ls_validkeytype


//ls_partner	= Trim(dw_master.Object.partnermst_partner[al_select_row])
//ls_contractseq	= Trim(String(dw_master.Object.contractmst_contractseq[al_select_row]))
ls_partner = Trim(String(dw_master.Object.partnermst_partner[al_select_row]))
ls_prefixno = Trim(String(dw_master.Object.partnermst_prefixno[al_select_row]))
ls_validkeytype = Trim(dw_master.Object.validkeymst_validkey_type[al_select_row])

//detail by master
If dw_master.DataObject = "b1dw_master_inq_validkeystock_1" Then
	dw_detail.DataObject = "b1dw_det_inq_validkeystock"
	dw_detail.SetTransObject(SQLCA)
	dw_detail.is_where = ls_where
	
Else
	dw_detail.DataObject = "b1dw_det_inq_validkeystock_1"
	dw_detail.SetTransObject(SQLCA)
	dw_detail.is_where = ls_where
	
End If


//Retrieve
If al_select_row > 0 Then
	If dw_master.DataObject = "b1dw_master_inq_validkeystock_1" then
		ls_priceplan = Trim(dw_master.Object.priceplan[al_select_row])
		If ls_priceplan = 'ALL' then
			ls_where = "substr(a.partner_prefix,1,3) = '"+ ls_prefixno +"' AND nvl(a.priceplan,'ALL') = '" + ls_priceplan + "' AND a.validkey_type = '" + ls_validkeytype +"' "
		Else	
	      ls_where = "substr(a.partner_prefix,1,3) = '"+ ls_prefixno +"' AND a.priceplan = '"+ ls_priceplan + "' AND a.validkey_type = '" + ls_validkeytype +"' "
	//ls_where = "mv_partner= '" + ls_partner + "' "
		End If
  Else
	ls_where = "substr(a.partner_prefix,1,3) = '"+ ls_prefixno +"' AND a.validkey_type = '" + ls_validkeytype +"' "
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

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

type st_horizontal from w_a_inq_m_m`st_horizontal within b1w_inq_validkeystock
integer x = 14
integer y = 888
end type

type p_1 from u_p_reset within b1w_inq_validkeystock
integer x = 2939
integer y = 52
boolean bringtotop = true
boolean originalsize = false
end type

