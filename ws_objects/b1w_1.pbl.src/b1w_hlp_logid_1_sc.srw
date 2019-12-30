$PBExportHeader$b1w_hlp_logid_1_sc.srw
$PBExportComments$[ceusee] LogID Check
forward
global type b1w_hlp_logid_1_sc from w_a_hlp
end type
end forward

global type b1w_hlp_logid_1_sc from w_a_hlp
integer width = 1509
integer height = 680
end type
global b1w_hlp_logid_1_sc b1w_hlp_logid_1_sc

type variables

end variables

on b1w_hlp_logid_1_sc.create
call super::create
end on

on b1w_hlp_logid_1_sc.destroy
call super::destroy
end on

event open;call super::open;This.Title = " Log ID Check"
p_ok.TriggerEvent("ue_disable")


end event

event ue_extra_ok_with_return;call super::ue_extra_ok_with_return;String ls_logid
iu_cust_help.ib_data[1] = True
ls_logid =Trim(dw_cond.Object.logid[1])
If IsNull(ls_logid) Then ls_logid =""
iu_cust_help.is_data[1] = ls_logid


end event

event ue_find();call super::ue_find;//Email 찾기
String ls_logid , ls_where
Long ll_row

ls_logid = Trim(dw_cond.object.logid[1])
If IsNull(ls_logid) Then ls_logid = ""

If ls_logid = "" Then
	f_msg_Info(200, Title, "Email ID")
	Return 
End If


ls_where = ""
ls_where = "logid = '" + ls_logid + "' "
dw_hlp.is_where = ls_where
ll_row = dw_hlp.Retrieve()

If ll_row = 0 Then
	
	dw_hlp.object.message.Text = "사용 가능한 ID 입니다."
	                             
	p_ok.TriggerEvent("ue_enable")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
Else
 	dw_hlp.object.message.Text = "이미 존재하는 ID 입니다."
	 							 
	dw_cond.SetFocus()
	dw_cond.SetColumn("logid")
	p_ok.TriggerEvent("ue_disable")
End If



end event

event ue_ok();Long ll_row
Integer li_ret
ll_row = dw_hlp.GetSelectedRow( 0 ) 

If Upper(iu_cust_help.is_data[1]) = "CLOSEWITHRETURN" Then	
	Trigger Event ue_extra_ok_with_return(1, li_ret)   //고정적으로 갲 1 값을 가져온다.
	If li_ret < 0 Then
		Return
	End If
Else 
	Trigger Event ue_extra_ok( ll_row ,li_ret)
	If li_ret < 0 Then
		Return
	End If		
End If

iu_cust_help.ib_data[1] = True 							//Help값이 선정됨.
Close( This )

end event

event ue_close();call super::ue_close;Close(This)
end event

type p_1 from w_a_hlp`p_1 within b1w_hlp_logid_1_sc
integer x = 562
integer y = 468
end type

type dw_cond from w_a_hlp`dw_cond within b1w_hlp_logid_1_sc
integer x = 41
integer width = 1298
integer height = 132
string dataobject = "b1dw_cnd_reg_logid"
boolean livescroll = false
end type

type p_ok from w_a_hlp`p_ok within b1w_hlp_logid_1_sc
integer x = 864
integer y = 472
end type

type p_close from w_a_hlp`p_close within b1w_hlp_logid_1_sc
integer x = 1170
integer y = 472
end type

type gb_cond from w_a_hlp`gb_cond within b1w_hlp_logid_1_sc
integer x = 23
integer width = 1344
integer height = 200
end type

type dw_hlp from w_a_hlp`dw_hlp within b1w_hlp_logid_1_sc
integer x = 23
integer y = 232
integer width = 1454
integer height = 212
string dataobject = "b1dw_cnd_logid_1"
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_hlp::clicked;call super::clicked;//MessageBox("xpos",String (xpos) + "  "  + String(ypos) + String (dwo))
end event

