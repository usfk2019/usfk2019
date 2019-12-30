$PBExportHeader$b1w_reg_hotreqdtl_pop.srw
$PBExportComments$[ceusee] Hotbill 처리 POP
forward
global type b1w_reg_hotreqdtl_pop from b5w_reg_hotreqdtl
end type
end forward

global type b1w_reg_hotreqdtl_pop from b5w_reg_hotreqdtl
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
end type
global b1w_reg_hotreqdtl_pop b1w_reg_hotreqdtl_pop

on b1w_reg_hotreqdtl_pop.create
call super::create
end on

on b1w_reg_hotreqdtl_pop.destroy
call super::destroy
end on

event open;call super::open;//window 중앙에
Date ld_termdt
String ls_termdt
f_center_window(b1w_reg_hotreqdtl_pop)

//납입고객, 해지 요청일 사용하지 못하게
dw_cond.object.payid.protect = 1
dw_cond.object.termdt.protect = 1
dw_cond.Object.payid.Color = RGB(0, 0, 0)
dw_cond.Object.payid.Background.Color = RGB(255, 251, 240)
dw_cond.Object.termdt.Color = RGB(0, 0, 0)
dw_cond.Object.termdt.Background.Color = RGB(255, 251, 240)

ls_termdt = iu_cust_msg.is_data[2]

ld_termdt = date(MidA(ls_termdt,1,4) + "-" + MidA(ls_termdt,5,2) + "-" + MidA(ls_termdt,7,2))
dw_cond.object.payid[1] = iu_cust_msg.is_data[1]
dw_cond.object.termdt[1] = ld_termdt






end event

event closequery;Int li_rc
Long ll_return
String ls_errmsg

dw_detail.AcceptText()

If ib_save = False Then
	If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) or (dw_detail.RowCount() > 0 ) Then
		li_rc = MessageBox(This.Title, "HotBill을 취소 하시겠습니까?",&
			Question!, YesNo!)
		If li_rc =1 Then
			ll_return = -1
			ls_errmsg = space(256)
			
			SQLCA.HOTCLEAR(is_payid, gs_user_id, ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"1 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				Return 1
				
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "1 " + ls_errmsg)
				Return 1
			End If 
			
			Close(this)
		Else
			Return 1
		End If
	End If
Else
	Close(this)
End If

Return 0
end event

event type integer ue_cancel();Integer li_return, i
Long ll_return
String ls_errmsg
Date ld_null

ll_return = -1
ls_errmsg = space(256)

SQLCA.HOTCLEAR(is_payid, gs_user_id, ll_return, ls_errmsg)
If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(Title+'~r~n'+"1 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
   Return -1
	
ElseIf ll_return < 0 Then	//For User
	MessageBox(Title, "1 " + ls_errmsg)
   Return -1
End If 

f_msg_info(3000, Title, "HotBilling Cancel")
ib_save = true

For i =1 To dw_detail.RowCount()
	 dw_detail.SetItemStatus(i,0,Primary!,NotModified!)
Next

	
p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

SetNull(ld_null)
dw_detail.Reset()
dw_cond.Enabled = True
dw_cond.object.pay_method[1] = ""

dw_cond.object.paydt[1] = date(fdt_get_dbserver_now())
p_cancel.TriggerEvent("ue_disable")
cb_hotbill.Enabled = True
dw_cond.SetFocus()
	

Return 0
end event

type dw_cond from b5w_reg_hotreqdtl`dw_cond within b1w_reg_hotreqdtl_pop
end type

event dw_cond::ue_init();Return 
end event

event dw_cond::doubleclicked;Return 0
end event

type p_ok from b5w_reg_hotreqdtl`p_ok within b1w_reg_hotreqdtl_pop
end type

type p_close from b5w_reg_hotreqdtl`p_close within b1w_reg_hotreqdtl_pop
end type

type gb_cond from b5w_reg_hotreqdtl`gb_cond within b1w_reg_hotreqdtl_pop
end type

type dw_detail from b5w_reg_hotreqdtl`dw_detail within b1w_reg_hotreqdtl_pop
end type

type p_delete from b5w_reg_hotreqdtl`p_delete within b1w_reg_hotreqdtl_pop
end type

type p_insert from b5w_reg_hotreqdtl`p_insert within b1w_reg_hotreqdtl_pop
end type

type p_save from b5w_reg_hotreqdtl`p_save within b1w_reg_hotreqdtl_pop
end type

type p_reset from b5w_reg_hotreqdtl`p_reset within b1w_reg_hotreqdtl_pop
boolean visible = false
end type

type p_cancel from b5w_reg_hotreqdtl`p_cancel within b1w_reg_hotreqdtl_pop
end type

type cb_hotbill from b5w_reg_hotreqdtl`cb_hotbill within b1w_reg_hotreqdtl_pop
end type

