$PBExportHeader$b1w_inq_validkeyquota.srw
$PBExportComments$[ssong] 대리점 인증키 할당내역조회
forward
global type b1w_inq_validkeyquota from w_a_inq_m_m
end type
type p_1 from u_p_reset within b1w_inq_validkeyquota
end type
end forward

global type b1w_inq_validkeyquota from w_a_inq_m_m
integer width = 3598
integer height = 2008
event ue_reset ( )
p_1 p_1
end type
global b1w_inq_validkeyquota b1w_inq_validkeyquota

event ue_reset();dw_cond.reset()
dw_cond.insertrow(1)

dw_master.reset()


dw_detail.reset()
end event

on b1w_inq_validkeyquota.create
int iCurrent
call super::create
this.p_1=create p_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
end on

on b1w_inq_validkeyquota.destroy
call super::destroy
destroy(this.p_1)
end on

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_partner
String	ls_requestfrom, ls_requestto, ls_movefrom, ls_moveto
String   ls_validkeytype


ls_partner		 = Trim(dw_cond.Object.partner[1])
ls_validkeytype = Trim(dw_cond.Object.validkey_type[1])
//ls_prmtype	 = Trim(dw_cond.Object.prmtype[1])
//ls_svccod		 = Trim(dw_cond.Object.svccod[1])
ls_requestfrom  = Trim(String(dw_cond.object.request_from[1],'yyyymmdd'))
ls_requestto	 = Trim(String(dw_cond.object.request_to[1],'yyyymmdd'))
ls_movefrom		 = Trim(String(dw_cond.object.move_from[1],'yyyymmdd'))
ls_moveto		 = Trim(String(dw_cond.object.move_to[1],'yyyymmdd'))


If( IsNull(ls_partner) ) Then ls_partner = ""
If( IsNull(ls_validkeytype) ) Then ls_validkeytype = ""
If( IsNull(ls_requestfrom) ) Then ls_requestfrom = ""
If( IsNull(ls_requestto) ) Then ls_requestto = ""
If( IsNull(ls_movefrom) ) Then ls_movefrom = ""
If( IsNull(ls_moveto) ) Then ls_moveto = ""

//필수사항 check

If ls_partner = "" Then
	f_msg_info(200, Title, "대리점")
	dw_cond.SetFocus()
	dw_cond.setColumn("partner")
	Return 
End If

//requestdate check

If ls_requestto <> "" Then
		If ls_requestfrom <> "" Then
			If ls_requestfrom > ls_requestto Then
				f_msg_info(200, Title, "요청일자(From) <= 요청일자(To)")
				Return
			End If
		End If
	End If
	
//movedate check

If ls_moveto <> "" Then
		If ls_movefrom <> "" Then
			If ls_movefrom > ls_moveto Then
				f_msg_info(200, Title, "할당일자(From) <= 할당일자(To)")
				Return
			End If
		End If
	End If


//Dynamic SQL
ls_where = ""

If( ls_partner <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "b.to_partner = '"+ ls_partner +"' "
End If

If( ls_validkeytype <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "a.validkey_type = '"+ ls_validkeytype +"' "
End If

If( ls_requestfrom <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(b.crtdt, 'YYYYMMDD') >= '"+ ls_requestfrom +"' "
End If

If( ls_requestto <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(b.crtdt, 'YYYYMMDD') <= '"+ ls_requestto +"' "
End If

If( ls_movefrom <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(b.movedt, 'YYYYMMDD') >= '"+ ls_movefrom +"' "
End If

If( ls_moveto <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(b.movedt, 'YYYYMMDD') <= '"+ ls_moveto +"' "
End If


dw_master.is_where	= ls_where

//Retrieve
ll_rows	= dw_master.Retrieve()
If( ll_rows = 0 ) Then
	f_msg_info(1000, Title, "")
	TriggerEvent("ue_reset")
ElseIf( ll_rows < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

end event

type dw_cond from w_a_inq_m_m`dw_cond within b1w_inq_validkeyquota
integer x = 78
integer y = 60
integer width = 2441
integer height = 232
string dataobject = "b1dw_cnd_inq_validkeyquota"
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

type p_ok from w_a_inq_m_m`p_ok within b1w_inq_validkeyquota
integer x = 2651
end type

type p_close from w_a_inq_m_m`p_close within b1w_inq_validkeyquota
integer x = 3246
boolean originalsize = false
end type

type gb_cond from w_a_inq_m_m`gb_cond within b1w_inq_validkeyquota
integer x = 18
integer width = 2619
integer height = 320
end type

type dw_master from w_a_inq_m_m`dw_master within b1w_inq_validkeyquota
integer x = 23
integer y = 348
integer width = 3511
integer height = 532
string dataobject = "b1dw_master_inq_validkeyquota"
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

ldwo_sort = Object.validkey_request_crtdt_t
uf_init( ldwo_sort, "A", RGB(0,0,128) )
end event

type dw_detail from w_a_inq_m_m`dw_detail within b1w_inq_validkeyquota
integer x = 23
integer y = 912
integer width = 3511
integer height = 952
string dataobject = "b1dw_det_inq_validkeyquota"
end type

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;String	ls_where
Long		ll_rows
String	ls_moveno, ls_validkeytype


ls_moveno	= Trim(String(dw_master.Object.validkey_move_moveno[al_select_row]))
ls_validkeytype = Trim(dw_master.Object.validkey_move_validkey_type[al_select_row])

//Retrieve
If al_select_row > 0 Then
	ls_where = "to_char(moveno) = '"+ ls_moveno +"' AND validkey_type = '" + ls_validkeytype +"' "
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

type st_horizontal from w_a_inq_m_m`st_horizontal within b1w_inq_validkeyquota
integer x = 14
integer y = 880
end type

type p_1 from u_p_reset within b1w_inq_validkeyquota
integer x = 2953
integer y = 52
boolean bringtotop = true
boolean originalsize = false
end type

