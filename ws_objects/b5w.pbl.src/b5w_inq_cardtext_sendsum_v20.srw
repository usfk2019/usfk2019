$PBExportHeader$b5w_inq_cardtext_sendsum_v20.srw
$PBExportComments$[ssong] 신용카드청구요청조회 - Window
forward
global type b5w_inq_cardtext_sendsum_v20 from w_a_inq_m_m
end type
type p_1 from u_p_reset within b5w_inq_cardtext_sendsum_v20
end type
type p_saveas from u_p_saveas within b5w_inq_cardtext_sendsum_v20
end type
end forward

global type b5w_inq_cardtext_sendsum_v20 from w_a_inq_m_m
integer width = 3598
integer height = 2008
event ue_reset ( )
event ue_saveas ( )
p_1 p_1
p_saveas p_saveas
end type
global b5w_inq_cardtext_sendsum_v20 b5w_inq_cardtext_sendsum_v20

type variables
String is_approval, is_billing, is_send
end variables

event ue_reset();dw_cond.reset()
dw_cond.insertrow(1)

dw_master.reset()


dw_detail.reset()
end event

event ue_saveas();Boolean lb_return
Integer li_return
String ls_curdir
u_api lu_api

If dw_detail.RowCount() <= 0 Then
	f_msg_info(1000, This.Title, "Data exporting")
	Return
End If

lu_api = Create u_api
ls_curdir = lu_api.uf_getcurrentdirectorya()
If IsNull(ls_curdir) Or ls_curdir = "" Then
	f_msg_info(9000, This.Title, "Can't get the Information of current directory.")
	Destroy lu_api
	Return
End If

li_return = dw_detail.SaveAs("", Excel!, True)

lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)
If li_return <> 1 Then
	f_msg_info(9000, This.Title, "User cancel current job.")
	
Else
	f_msg_info(9000, This.Title, "Data export finished.")
End If

Destroy lu_api

//저장을 못하거나 완료 하면 삭제한다.
//Delete curr_tmpcdr
//where emp_id = :gs_user_id
//and to_char(stime, 'yyyymmddhh24') >= :is_fromdt 
//and to_char(stime, 'yyyymmddhh24') <= :is_todt;
//
//If sqlca.sqlcode < 0 Then
//	f_msg_sql_err(title, "Delete curr_tmpcdr")				
//	Return 
//End If
//
//commit;
//

//p_1.TriggerEvent("ue_disable")




end event

on b5w_inq_cardtext_sendsum_v20.create
int iCurrent
call super::create
this.p_1=create p_1
this.p_saveas=create p_saveas
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
this.Control[iCurrent+2]=this.p_saveas
end on

on b5w_inq_cardtext_sendsum_v20.destroy
call super::destroy
destroy(this.p_1)
destroy(this.p_saveas)
end on

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_card_type, ls_memberid, ls_file_name
String	ls_workdt_fr, ls_workdt_to


ls_card_type  = Trim(dw_cond.Object.card_type[1])
ls_memberid   = Trim(dw_cond.Object.memberid[1])
ls_file_name  = Trim(dw_cond.Object.file_name[1])
ls_workdt_fr  = Trim(String(dw_cond.Object.workdt_fr[1],'yyyymmdd'))
ls_workdt_to  = Trim(String(dw_cond.Object.workdt_to[1],'yyyymmdd'))


If( IsNull(ls_card_type) ) Then ls_card_type = ""
If( IsNull(ls_memberid) ) Then ls_memberid = ""
If( IsNull(ls_file_name) ) Then ls_file_name = ""
If( IsNull(ls_workdt_fr) ) Then ls_workdt_fr = ""
If( IsNull(ls_workdt_to) ) Then ls_workdt_to = ""


//Dynamic SQL
ls_where = ""

If( ls_card_type <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "B.card_type = '"+ ls_card_type +"'"
End If

If( ls_memberid <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "A.memberid = '"+ ls_memberid +"'"
End If

If( ls_file_name <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "A.file_name = '"+ ls_file_name +"'"
End If

If( ls_workdt_fr <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(A.workdt, 'YYYYMMDD') >= '"+ ls_workdt_fr +"'"
End If

If( ls_workdt_to <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(A.workdt, 'YYYYMMDD') <= '"+ ls_workdt_to +"'"
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

event open;call super::open;String ls_ref_desc, ls_temp, ls_name[]

ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("B7", "C110", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", ls_name[])
is_approval = ls_name[2]
is_billing = ls_name[4]
is_send = ls_name[7]
end event

type dw_cond from w_a_inq_m_m`dw_cond within b5w_inq_cardtext_sendsum_v20
integer x = 55
integer y = 52
integer width = 2501
integer height = 268
string dataobject = "b5dw_inq_cnd_cardtext_sendsum_v20"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type p_ok from w_a_inq_m_m`p_ok within b5w_inq_cardtext_sendsum_v20
integer x = 2638
end type

type p_close from w_a_inq_m_m`p_close within b5w_inq_cardtext_sendsum_v20
integer x = 3232
boolean originalsize = false
end type

type gb_cond from w_a_inq_m_m`gb_cond within b5w_inq_cardtext_sendsum_v20
integer x = 18
integer width = 2551
integer height = 340
end type

type dw_master from w_a_inq_m_m`dw_master within b5w_inq_cardtext_sendsum_v20
integer x = 23
integer y = 360
integer width = 3511
integer height = 520
string dataobject = "b5dw_inq_mst_cardtext_sendsum_v20"
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

event dw_master::ue_init;call super::ue_init;dwObject ldwo_sort

ldwo_sort = Object.workdt_t
uf_init( ldwo_sort, "D", RGB(0,0,128) )
end event

type dw_detail from w_a_inq_m_m`dw_detail within b5w_inq_cardtext_sendsum_v20
integer x = 23
integer y = 912
integer width = 3511
integer height = 952
string dataobject = "b5dw_inq_det_cardtext_sendsum_v20"
end type

event dw_detail::ue_retrieve;call super::ue_retrieve;String	ls_where
Long		ll_rows
String	ls_memberid, ls_approval_fromdt, ls_approval_todt, ls_card_type


ls_memberid	         = Trim(dw_master.Object.memberid[al_select_row])
ls_approval_fromdt	= Trim(String(dw_master.Object.approval_fromdt[al_select_row],'yyyymmdd'))
ls_approval_todt	= Trim(String(dw_master.Object.approval_todt[al_select_row],'yyyymmdd'))
ls_card_type = Trim(dw_cond.Object.card_type[1])

If Isnull(ls_card_type) Then ls_card_type = ""

//Retrieve
If al_select_row > 0 Then
	ls_where += "memberid = '"+ ls_memberid +"' AND to_char(approvaldt,'yyyymmdd') >= '" + ls_approval_fromdt + "' AND to_char(approvaldt,'yyyymmdd') <= '" + ls_approval_todt + "' AND (status = '" + is_approval + "' OR status = '" + is_billing + "' OR status = '" + is_send + "') AND card_type =  nvl('" +ls_card_type + "', card_type)" 
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

type st_horizontal from w_a_inq_m_m`st_horizontal within b5w_inq_cardtext_sendsum_v20
integer x = 14
integer y = 880
end type

type p_1 from u_p_reset within b5w_inq_cardtext_sendsum_v20
integer x = 2939
integer y = 52
boolean bringtotop = true
boolean originalsize = false
end type

type p_saveas from u_p_saveas within b5w_inq_cardtext_sendsum_v20
integer x = 2944
integer y = 172
boolean bringtotop = true
end type

