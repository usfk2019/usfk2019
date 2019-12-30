$PBExportHeader$b4w_inq_penaltydet.srw
$PBExportComments$[chooys] 위약금내역조회 - Window
forward
global type b4w_inq_penaltydet from w_a_inq_m_m
end type
type p_1 from u_p_reset within b4w_inq_penaltydet
end type
end forward

global type b4w_inq_penaltydet from w_a_inq_m_m
integer width = 3598
integer height = 2008
event ue_reset ( )
p_1 p_1
end type
global b4w_inq_penaltydet b4w_inq_penaltydet

event ue_reset();dw_cond.reset()
dw_cond.insertrow(1)

dw_master.reset()


dw_detail.reset()
end event

on b4w_inq_penaltydet.create
int iCurrent
call super::create
this.p_1=create p_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
end on

on b4w_inq_penaltydet.destroy
call super::destroy
destroy(this.p_1)
end on

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_customerid, ls_prmtype
String	ls_svccod, ls_termdtfrom, ls_termdtto


ls_customerid		= Trim(dw_cond.Object.customerid[1])
ls_prmtype			= Trim(dw_cond.Object.prmtype[1])
ls_svccod			= Trim(dw_cond.Object.svccod[1])
ls_termdtfrom		= Trim(String(dw_cond.object.termdtfrom[1],'yyyymmdd'))
ls_termdtto			= Trim(String(dw_cond.object.termdtto[1],'yyyymmdd'))

If( IsNull(ls_customerid) ) Then ls_customerid = ""
If( IsNull(ls_prmtype) ) Then ls_prmtype = ""
If( IsNull(ls_svccod) ) Then ls_svccod = ""
If( IsNull(ls_termdtfrom) ) Then ls_termdtfrom = ""
If( IsNull(ls_termdtto) ) Then ls_termdtto = ""


//Dynamic SQL
ls_where = ""

If( ls_customerid <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "penaltydet.customerid = '"+ ls_customerid +"'"
End If

If( ls_prmtype <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "penaltydet.prmtype = '"+ ls_prmtype +"'"
End If

If( ls_svccod <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "penaltydet.svccod = '"+ ls_svccod +"'"
End If

If( ls_termdtfrom <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(penaltydet.termdt, 'YYYYMMDD') >= '"+ ls_termdtfrom +"'"
End If

If( ls_termdtto <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(penaltydet.termdt, 'YYYYMMDD') <= '"+ ls_termdtto +"'"
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

type dw_cond from w_a_inq_m_m`dw_cond within b4w_inq_penaltydet
integer x = 55
integer y = 52
integer width = 2501
integer height = 208
string dataobject = "b4dw_cnd_inqpenaltydet"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::ue_init();call super::ue_init;idwo_help_col[1] = Object.customerid
is_help_win[1] = "b1w_hlp_customerm"
is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.Name
	Case "customerid"
		If iu_cust_help.ib_data[1] Then
			Object.customerid[row] = iu_cust_help.is_data[1]
			Object.customernm[row] = iu_cust_help.is_data[2]
		End If
		
End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;Choose Case Dwo.Name
	Case "customerid"
		Object.customernm[1] = ""
		
End Choose
end event

type p_ok from w_a_inq_m_m`p_ok within b4w_inq_penaltydet
integer x = 2638
end type

type p_close from w_a_inq_m_m`p_close within b4w_inq_penaltydet
integer x = 3232
integer y = 52
boolean originalsize = false
end type

type gb_cond from w_a_inq_m_m`gb_cond within b4w_inq_penaltydet
integer x = 18
integer width = 2551
end type

type dw_master from w_a_inq_m_m`dw_master within b4w_inq_penaltydet
integer x = 23
integer y = 304
integer width = 3511
integer height = 576
string dataobject = "b4dw_inq_penaltydet"
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

ldwo_sort = Object.penaltydet_customerid_t
uf_init( ldwo_sort, "A", RGB(0,0,128) )
end event

type dw_detail from w_a_inq_m_m`dw_detail within b4w_inq_penaltydet
integer x = 23
integer y = 912
integer width = 3511
integer height = 952
string dataobject = "b4dw_inq_detail_inqpenaltydet"
end type

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;String	ls_where
Long		ll_rows
String	ls_customerid, ls_contractseq


ls_customerid	= Trim(dw_master.Object.penaltydet_customerid[al_select_row])
ls_contractseq	= Trim(String(dw_master.Object.contractmst_contractseq[al_select_row]))

//Retrieve
If al_select_row > 0 Then
	ls_where = "penaltydet.customerid = '"+ ls_customerid +"' AND contractmst.contractseq = "+ ls_contractseq +""
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

type st_horizontal from w_a_inq_m_m`st_horizontal within b4w_inq_penaltydet
integer x = 14
integer y = 880
end type

type p_1 from u_p_reset within b4w_inq_penaltydet
integer x = 2939
integer y = 52
boolean bringtotop = true
boolean originalsize = false
end type

