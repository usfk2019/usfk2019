$PBExportHeader$rpt0w_reg_rptcontrol_update_pop.srw
$PBExportComments$[parkkh] rptcontrol update popup window
forward
global type rpt0w_reg_rptcontrol_update_pop from w_a_reg_m
end type
end forward

global type rpt0w_reg_rptcontrol_update_pop from w_a_reg_m
integer width = 3159
integer height = 820
string title = ""
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
end type
global rpt0w_reg_rptcontrol_update_pop rpt0w_reg_rptcontrol_update_pop

type variables
String is_pgm_id, is_rptcontgroup, is_rptcont



end variables

on rpt0w_reg_rptcontrol_update_pop.create
call super::create
end on

on rpt0w_reg_rptcontrol_update_pop.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	rpt0w_reg_rptcontrol_update_pop
	Desc	: 	계정Control등록 - update popup
	Ver.	:	1.0
	Date	: 	2003.10.29
	programer : park kyung hae(parkkh)
-------------------------------------------------------------------------*/

//window 중앙에
f_center_window(rpt0w_reg_rptcontrol_update_pop)

is_rptcont = iu_cust_msg.is_data[1]    //rptcont
is_pgm_id = iu_cust_msg.is_data[2]     //프로그램 id
is_rptcontgroup = iu_cust_msg.is_data[3]     //rptcontgroup

TriggerEvent("ue_ok")
end event

event ue_ok();call super::ue_ok;String ls_where
Long ll_row

//retrieve
ls_where = " rptcont = '" + is_rptcont + "' "  

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
   Return
End If

p_save.TriggerEvent("ue_enable")
p_ok.TriggerEvent("ue_disable")

dw_detail.SetFocus()
end event

event resize;call super::resize;SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	p_close.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
else
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space
End If

SetRedraw(True)

end event

event type integer ue_extra_save();call super::ue_extra_save;Long ll_row, ll_cnt, li_rc
String ls_rptgroup, ls_rptdata, ls_rptcont, ls_rptcontnm, ls_rptcontgroup, ls_rptcode
rpt0u_dbmgr 	lu_dbmgr

ll_row = dw_detail.RowCount()
If ll_row = 0 Then Return 0 

ls_rptgroup = dw_detail.object.rptgroup[1]
ls_rptdata = dw_detail.object.rptdata[1]
ls_rptcont = dw_detail.object.rptcont[1]
ls_rptcontnm = dw_detail.object.rptcontnm[1]
ls_rptcontgroup = dw_detail.object.rptcontgroup[1]
ls_rptcode = dw_detail.object.rptcode[1]
If IsNull(ls_rptgroup) Then ls_rptgroup = ""
If IsNull(ls_rptdata) Then ls_rptdata = ""
If IsNull(ls_rptcont) Then ls_rptcont = ""
If IsNull(ls_rptcontnm) Then ls_rptcontnm = ""
If IsNull(ls_rptcontgroup) Then ls_rptcontgroup = ""
If IsNull(ls_rptcode) Then ls_rptcode = ""

//저장
lu_dbmgr = Create rpt0u_dbmgr
lu_dbmgr.is_caller = "r0w_reg_rptcontrol%dupl_check"
lu_dbmgr.is_title = Title
lu_dbmgr.is_data[1] = ls_rptcode   	//계정코드
lu_dbmgr.is_data[2] = ls_rptcont	//계정Cont코드

lu_dbmgr.uf_prc_db()
li_rc = lu_dbmgr.ii_rc

If li_rc = -1  Then
	Destroy lu_dbmgr
	Return li_rc
End If

If ls_rptgroup = "" Then
	f_msg_usr_err(200, Title, "계정TYPE")
	dw_detail.SetRow(1)
	dw_detail.ScrollToRow(1)
	dw_detail.SetColumn("rptgroup")
	Return - 1
End If

If ls_rptdata = "" Then
	f_msg_usr_err(200, Title, "실제DATA")
	dw_detail.SetRow(1)
	dw_detail.ScrollToRow(1)
	dw_detail.SetColumn("rptdata")
	Return - 1
End If

If ls_rptcont = "" Then
	f_msg_usr_err(200, Title, "계정Control")
	dw_detail.SetRow(1)
	dw_detail.ScrollToRow(1)
	dw_detail.SetColumn("rptcontrol")
	Return - 1
End If

If ls_rptcontnm = "" Then
	f_msg_usr_err(200, Title, "계정Control명")
	dw_detail.SetRow(1)
	dw_detail.ScrollToRow(1)
	dw_detail.SetColumn("rptcontnm")
	Return - 1
End If		

If ls_rptcontgroup = "" Then
	f_msg_usr_err(200, Title, "계정Control그룹")
	dw_detail.SetRow(1)
	dw_detail.ScrollToRow(1)
	dw_detail.SetColumn("rptcontgroup")
	Return - 1
End If		

If ls_rptcode = "" Then
	f_msg_usr_err(200, Title, "계정코드")
	dw_detail.SetRow(1)
	dw_detail.ScrollToRow(1)
	dw_detail.SetColumn("rptcode")
	Return - 1
End If		

Return 0 
end event

event type integer ue_save();Constant Int LI_ERROR = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

If dw_detail.Update() < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If

	f_msg_info(3010,This.Title,"Save")
	Return LI_ERROR
Else
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	
	f_msg_info(3000,This.Title,"Save")
End If

//P_save.TriggerEvent("ue_disable")
//dw_detail.enabled = False

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within rpt0w_reg_rptcontrol_update_pop
boolean visible = false
integer x = 23
integer y = 24
integer width = 1810
integer height = 264
integer taborder = 10
string dataobject = "b1dw_cnd_reg_validinfo_popup"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within rpt0w_reg_rptcontrol_update_pop
boolean visible = false
integer x = 585
integer y = 1228
end type

type p_close from w_a_reg_m`p_close within rpt0w_reg_rptcontrol_update_pop
integer x = 2798
integer y = 604
end type

type gb_cond from w_a_reg_m`gb_cond within rpt0w_reg_rptcontrol_update_pop
boolean visible = false
end type

type p_delete from w_a_reg_m`p_delete within rpt0w_reg_rptcontrol_update_pop
boolean visible = false
integer x = 50
integer y = 1432
end type

type p_insert from w_a_reg_m`p_insert within rpt0w_reg_rptcontrol_update_pop
boolean visible = false
end type

type p_save from w_a_reg_m`p_save within rpt0w_reg_rptcontrol_update_pop
integer x = 2487
integer y = 604
boolean enabled = true
end type

type dw_detail from w_a_reg_m`dw_detail within rpt0w_reg_rptcontrol_update_pop
integer y = 52
integer width = 3058
integer height = 480
integer taborder = 20
string dataobject = "rpt0dw_reg_rptcontrol_update_pop"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::itemchanged;call super::itemchanged;
Choose Case dwo.name
	case "rptgroup" 
	
		Choose Case Upper(data)
			Case "PRICEPL"  
				This.Modify("rptdata.dddw.name=''")
				This.Modify("rptdata.dddw.DataColumn=''")
				This.Modify("rptdata.dddw.DisplayColumn=''")
				This.Object.rptdata[row] = ''				
				This.Modify("rptdata.dddw.name=rpt0dc_dddw_priceplan")
				This.Modify("rptdata.dddw.DataColumn='priceplan'")
				This.Modify("rptdata.dddw.DisplayColumn='priceplan_desc'")
				
			Case "SVCCODE"		
				This.Modify("rptdata.dddw.name=''")
				This.Modify("rptdata.dddw.DataColumn=''")
				This.Modify("rptdata.dddw.DisplayColumn=''")
				This.Object.rptdata[row] = ''				
				This.Modify("rptdata.dddw.name=rpt0dc_dddw_svcmst")
				This.Modify("rptdata.dddw.DataColumn='svccod'")
				This.Modify("rptdata.dddw.DisplayColumn='svcdesc'")
				 
			Case "ZONCODE"		
				This.Modify("rptdata.dddw.name=''")
				This.Modify("rptdata.dddw.DataColumn=''")
				This.Modify("rptdata.dddw.DisplayColumn=''")
				This.Object.rptdata[row] = ''				
				This.Modify("rptdata.dddw.name=rpt0dc_dddw_zone")
				This.Modify("rptdata.dddw.DataColumn='zoncod'")
				This.Modify("rptdata.dddw.DisplayColumn='zonnm'")

			Case "ITEMCOD"		
				This.Modify("rptdata.dddw.name=''")
				This.Modify("rptdata.dddw.DataColumn=''")
				This.Modify("rptdata.dddw.DisplayColumn=''")
				This.Object.rptdata[row] = ''				
				This.Modify("rptdata.dddw.name=rpt0dc_dddw_itemcod")
				This.Modify("rptdata.dddw.DataColumn='itemcod'")
				This.Modify("rptdata.dddw.DisplayColumn='itemnm'")			
				
			Case else				
				This.Modify("rptdata.dddw.name=''")
				This.Modify("rptdata.dddw.DataColumn=''")
				This.Modify("rptdata.dddw.DisplayColumn=''")
				This.Object.rptdata[row] = ''				
				
		End Choose
	
		This.object.rptcont[1] = Upper(LeftA(trim(data),6)) + '_' + Trim(object.rptcontgroup[1]) + '_'+ Trim(object.rptdata[1])
		
	
	case "rptdata"
		
		This.object.rptcont[1] = Upper(LeftA(Trim(object.rptgroup[1]),6)) + '_' + Trim(object.rptcontgroup[1]) + '_' + Trim(object.rptdata[1])
	
End Choose

return 0
end event

event dw_detail::retrieveend;call super::retrieveend;String ls_rptgroup, ls_rptcont, ls_rptdata

ls_rptgroup = This.object.rptgroup[1]
ls_rptcont = This.object.rptcont[1]
ls_rptdata = MidA(This.object.rptcont[1],12)

Choose Case Upper(ls_rptgroup)
		
		Case "PRICEP"  
			This.Modify("rptdata.dddw.name=''")
			This.Modify("rptdata.dddw.DataColumn=''")
			This.Modify("rptdata.dddw.DisplayColumn=''")
			This.Object.rptdata[1] = ''				
			This.Modify("rptdata.dddw.name=rpt0dc_dddw_priceplan")
			This.Modify("rptdata.dddw.DataColumn='priceplan'")
			This.Modify("rptdata.dddw.DisplayColumn='priceplan_desc'")
			This.Object.rptdata[1] = ls_rptdata
				
		Case "SVCCOD"		
			This.Modify("rptdata.dddw.name=''")
			This.Modify("rptdata.dddw.DataColumn=''")
			This.Modify("rptdata.dddw.DisplayColumn=''")
			This.Object.rptdata[1] = ''				
			This.Modify("rptdata.dddw.name=rpt0dc_dddw_svcmst")
			This.Modify("rptdata.dddw.DataColumn='svccod'")
			This.Modify("rptdata.dddw.DisplayColumn='svcdesc'")
			This.Object.rptdata[1] = ls_rptdata
			 
		Case "ZONCOD"		
			This.Modify("rptdata.dddw.name=''")
			This.Modify("rptdata.dddw.DataColumn=''")
			This.Modify("rptdata.dddw.DisplayColumn=''")
			This.Object.rptdata[1] = ''				
			This.Modify("rptdata.dddw.name=rpt0dc_dddw_zone")
			This.Modify("rptdata.dddw.DataColumn='zoncod'")
			This.Modify("rptdata.dddw.DisplayColumn='zonnm'")
			This.Object.rptdata[1] = ls_rptdata

		Case "ITEMCO"		
			This.Modify("rptdata.dddw.name=''")
			This.Modify("rptdata.dddw.DataColumn=''")
			This.Modify("rptdata.dddw.DisplayColumn=''")
			This.Object.rptdata[1] = ''				
			This.Modify("rptdata.dddw.name=rpt0dc_dddw_itemcod")
			This.Modify("rptdata.dddw.DataColumn='itemcod'")
			This.Modify("rptdata.dddw.DisplayColumn='itemnm'")			
			This.Object.rptdata[1] = ls_rptdata
			
			
		Case else				
			This.Modify("rptdata.dddw.name=''")
			This.Modify("rptdata.dddw.DataColumn=''")
			This.Modify("rptdata.dddw.DisplayColumn=''")
			This.Object.rptdata[1] = ''				
	
End Choose

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)
	
return 0
end event

type p_reset from w_a_reg_m`p_reset within rpt0w_reg_rptcontrol_update_pop
boolean visible = false
integer x = 270
integer y = 1224
boolean enabled = true
end type

