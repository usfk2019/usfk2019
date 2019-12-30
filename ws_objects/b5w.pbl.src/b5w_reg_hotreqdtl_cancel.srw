$PBExportHeader$b5w_reg_hotreqdtl_cancel.srw
$PBExportComments$[ceusee] Hot Bill 취소
forward
global type b5w_reg_hotreqdtl_cancel from w_a_reg_s
end type
type p_cancel from u_p_cancel within b5w_reg_hotreqdtl_cancel
end type
end forward

global type b5w_reg_hotreqdtl_cancel from w_a_reg_s
integer width = 2171
integer height = 1760
event type integer ue_cancel ( )
p_cancel p_cancel
end type
global b5w_reg_hotreqdtl_cancel b5w_reg_hotreqdtl_cancel

type variables
String is_hotflag, is_payid, is_termdt
boolean ib_save
Integer il_cnt
end variables

forward prototypes
public function integer wfi_get_hotbill_use (integer ai_work, string as_payid)
end prototypes

event type integer ue_cancel();Integer li_return, i
Long ll_return
String ls_errmsg

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
For i =1 To dw_detail.RowCount()
	 dw_detail.SetItemStatus(i,0,Primary!,NotModified!)
Next

ib_save = true
TriggerEvent("ue_reset")  //리셋한다.

Return 0
end event

public function integer wfi_get_hotbill_use (integer ai_work, string as_payid);Return 0
end function

on b5w_reg_hotreqdtl_cancel.create
int iCurrent
call super::create
this.p_cancel=create p_cancel
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_cancel
end on

on b5w_reg_hotreqdtl_cancel.destroy
call super::destroy
destroy(this.p_cancel)
end on

event open;call super::open;String ls_format, ls_ref_desc, ls_tmp, ls_useyn

ls_format = fs_get_control("B5", "H200", ls_ref_desc)
If ls_format = "1" Then
	dw_detail.object.tramt.Format = "#,##0.0"
	dw_detail.object.adjamt.Format = "#,##0.0"
	dw_detail.object.preamt.Format = "#,##0.0"	
	dw_detail.object.balance.Format = "#,##0.0"	
	dw_detail.object.totamt.Format = "#,##0.0"	
	dw_detail.object.sum_amt.Format = "#,##0.0"	
ElseIf ls_format = "2" Then
	dw_detail.object.tramt.Format = "#,##0.00"
	dw_detail.object.adjamt.Format = "#,##0.00"
	dw_detail.object.preamt.Format = "#,##0.00"	
	dw_detail.object.balance.Format = "#,##0.00"	
	dw_detail.object.totamt.Format = "#,##0.00"	
	dw_detail.object.sum_amt.Format = "#,##0.0"	
Else
	dw_detail.object.tramt.Format = "#,##0"
	dw_detail.object.adjamt.Format = "#,##0"
	dw_detail.object.preamt.Format = "#,##0"	
	dw_detail.object.balance.Format = "#,##0"	
	dw_detail.object.totamt.Format = "#,##0"	
	dw_detail.object.sum_amt.Format = "#,##0"
End If
ib_save = False





end event

event resize;call super::resize;If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0

	p_cancel.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space

Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space

	p_cancel.Y	= newheight - iu_cust_w_resize.ii_button_space

End If
end event

event ue_ok();call super::ue_ok;Long ll_row
is_payid = dw_cond.object.payid[1]

ll_row = dw_detail.Retrieve(is_payid)
If ll_row = 0 Then
	f_msg_info(1000, title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, title, "Retrieve()")
	Return
End If

Return
end event

event type integer ue_reset();call super::ue_reset;p_cancel.TriggerEvent("ue_disable")

Return 0 
end event

type dw_cond from w_a_reg_s`dw_cond within b5w_reg_hotreqdtl_cancel
integer y = 80
integer width = 1554
integer height = 160
string dataobject = "b5dw_cnd_reg_hotbill_cancel"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;This.idwo_help_col[1] = This.Object.payid
This.is_help_win[1] = "b5w_hlp_paymst_hotbill"
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;dwObject ldwo_payid


Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
		
			Object.payid[row] = iu_cust_help.is_data2[1]		//고객번호

		End If		
End Choose



Return 0
end event

event dw_cond::itemchanged;call super::itemchanged;If dwo.name = "payid" Then
	This.object.payid_1[row] = data
End If

Return 0
end event

type p_ok from w_a_reg_s`p_ok within b5w_reg_hotreqdtl_cancel
integer x = 1746
end type

type p_close from w_a_reg_s`p_close within b5w_reg_hotreqdtl_cancel
integer x = 1746
integer y = 164
boolean originalsize = false
end type

type gb_cond from w_a_reg_s`gb_cond within b5w_reg_hotreqdtl_cancel
integer width = 1637
integer height = 272
end type

type dw_detail from w_a_reg_s`dw_detail within b5w_reg_hotreqdtl_cancel
integer y = 292
integer width = 2066
integer height = 1204
string dataobject = "b5dw_reg_hotbill_cancel"
end type

event dw_detail::retrieveend;call super::retrieveend;String ls_hotbillflag
If rowcount > 0 Then
  
  ls_hotbillflag = Trim(dw_detail.object.hotbillflag[1])
  If ls_hotbillflag = "S" Then  //처리할 수있다.
	 p_cancel.TriggerEvent("ue_enable")
  Else  //취소할 수 없다.
	p_cancel.TriggerEvent("ue_disable")

  End if
End If

Return 0
end event

type p_delete from w_a_reg_s`p_delete within b5w_reg_hotreqdtl_cancel
boolean visible = false
end type

type p_insert from w_a_reg_s`p_insert within b5w_reg_hotreqdtl_cancel
boolean visible = false
end type

type p_save from w_a_reg_s`p_save within b5w_reg_hotreqdtl_cancel
boolean visible = false
integer x = 46
integer y = 1528
end type

type p_reset from w_a_reg_s`p_reset within b5w_reg_hotreqdtl_cancel
integer x = 379
integer y = 1528
end type

type p_cancel from u_p_cancel within b5w_reg_hotreqdtl_cancel
integer x = 41
integer y = 1528
integer height = 92
boolean bringtotop = true
end type

