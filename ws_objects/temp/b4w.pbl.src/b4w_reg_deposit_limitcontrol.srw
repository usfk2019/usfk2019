$PBExportHeader$b4w_reg_deposit_limitcontrol.srw
$PBExportComments$[ssong] 보증금 한도 control 관리
forward
global type b4w_reg_deposit_limitcontrol from w_a_reg_m
end type
end forward

global type b4w_reg_deposit_limitcontrol from w_a_reg_m
end type
global b4w_reg_deposit_limitcontrol b4w_reg_deposit_limitcontrol

on b4w_reg_deposit_limitcontrol.create
call super::create
end on

on b4w_reg_deposit_limitcontrol.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
//	Name      :	b4w_reg_deposit_limitcontrol
//	Desc.     : 보증금 한도 관리
//	Date      : 2004.08.25
//  Ver.      : 1.0
//  Programer : Song Eun Mi (ssong)
-------------------------------------------------------------------------*/
dw_detail.SetRowFocusIndicator(Off!)
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Insert
dw_detail.object.svccod[al_insert_row] = Trim(dw_cond.object.svccod[1])
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("svccod")
dw_detail.SetItemStatus(al_insert_row, 0, Primary!, NotModified!)

//Log
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

Return 0
end event

event type integer ue_extra_save();call super::ue_extra_save;String ls_svccod, ls_limit_control
Dec    ldc_rate_from, ldc_rate_to
Long ll_row, i

String ls_email_yn,  ls_mtitle, ls_filenm, ls_sender
String ls_sms_yn, ls_sms_callback, ls_sms_msg

ll_row = dw_detail.Rowcount()

	For i =1 To ll_row
		ls_svccod 		  = Trim(dw_detail.object.svccod[i])
		ldc_rate_from	  = dw_detail.object.rate_from[i]
		ldc_rate_to      = dw_detail.object.rate_to[i]
		ls_limit_control = Trim(dw_detail.object.limit_control[i])
		ls_email_yn      = Trim(dw_detail.Object.email_yn[i])
		ls_sms_yn        = Trim(dw_detail.Object.sms_yn[i])
		ls_mtitle        = Trim(dw_detail.Object.mtitle[i])
		ls_filenm        = Trim(dw_detail.object.filenm[i])
		ls_sender        = Trim(dw_detail.Object.sender[i])
		ls_sms_callback  = Trim(dw_detail.Object.sms_callback[i])
		ls_sms_msg       = Trim(dw_detail.Object.sms_msg[i])
		
		If IsNull(ls_svccod)        Then ls_svccod = ""
		If IsNull(ldc_rate_from)    Then ldc_rate_from = 0
		If IsNull(ldc_rate_to)      Then ldc_rate_to = 0
		If IsNull(ls_limit_control) Then ls_limit_control = ""
		If IsNull(ls_mtitle)        Then ls_mtitle = ""
		If IsNull(ls_filenm)        Then ls_filenm = ""
		If IsNull(ls_sender)        Then ls_sender = ""
		If IsNull(ls_sms_callback)  Then ls_sms_callback = ""
		If IsNull(ls_sms_msg)       Then ls_sms_msg = ""
		
		If ls_svccod = "" Then
			f_msg_usr_err(200, Title, "서비스")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("svccod")
			dw_detail.SetRedraw(True)
			Return -1
		End If
		
		If ldc_rate_from <= 0 Then
			f_msg_usr_err(200, Title, "사용율from")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("rate_from")
			dw_detail.SetRedraw(True)
			Return -1
		End If
		
		If ls_limit_control = "" Then
			f_msg_usr_err(200, Title, "조치사항")
			dw_detail.SetRow(i)
			dw_detail.ScrollToRow(i)
			dw_detail.SetColumn("limit_control")
			dw_detail.SetRedraw(True)
			Return -1
		End If
		
		If ls_email_yn ='Y' Then
			If ls_mtitle ="" Then
				f_msg_usr_err(200, Title, "Email 제목")
				dw_detail.SetRow(i)
				dw_detail.ScrollToRow(i)
				dw_detail.SetColumn("mtitle")
				dw_detail.SetRedraw(True)
				Return -1
			End If
			
			If ls_filenm = "" Then
				f_msg_usr_err(200, Title, "Email File명")
				dw_detail.SetRow(i)
				dw_detail.ScrollToRow(i)
				dw_detail.SetColumn("filenm")
				dw_detail.SetRedraw(True)
				Return -1
			End If
			
			If ls_sender = "" Then
				f_msg_usr_err(200, Title, "Email 보내는 사람")
				dw_detail.SetRow(i)
				dw_detail.ScrollToRow(i)
				dw_detail.SetColumn("sender")
				dw_detail.SetRedraw(True)
				Return -1
			End If			
		End If
		
		If ls_sms_yn ='Y' Then
			If ls_sms_callback = "" Then
				f_msg_usr_err(200,Title, "SMS 회신번호")
				dw_detail.SetRow(i)
				dw_detail.ScrollToRow(i)
				dw_detail.SetColumn("sms_callback")
				dw_detail.SetRedraw(True)
				Return -1
			End If
			
			If ls_sms_msg = "" Then
				f_msg_usr_err(200, Title, "SMS Message")
				dw_detail.SetRow(i)
				dw_detail.ScrollToRow(i)
				dw_detail.SetColumn("sms_msg")
				dw_detail.SetRedraw(True)
				Return -1
			End If
		End If
		
		
	next
	
	
return 0
end event

event ue_ok();call super::ue_ok;//조건 조회
String ls_svccod, ls_where
Long ll_row

ls_svccod  = Trim(dw_cond.object.svccod[1])


If IsNull(ls_svccod) Then ls_svccod = ""


If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " svccod = '" + ls_svccod + "' "
End If


dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row =0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title,"Retrieve()")
	Return 
End If

p_insert.TriggerEvent("ue_enable")
p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

	
	
end event

type dw_cond from w_a_reg_m`dw_cond within b4w_reg_deposit_limitcontrol
integer x = 41
integer y = 64
integer width = 1166
integer height = 144
string dataobject = "b4dw_reg_cnd_deposit_limitcontrol"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within b4w_reg_deposit_limitcontrol
integer x = 1577
integer y = 76
end type

type p_close from w_a_reg_m`p_close within b4w_reg_deposit_limitcontrol
integer x = 1883
integer y = 76
end type

type gb_cond from w_a_reg_m`gb_cond within b4w_reg_deposit_limitcontrol
integer width = 1467
integer height = 276
end type

type p_delete from w_a_reg_m`p_delete within b4w_reg_deposit_limitcontrol
end type

type p_insert from w_a_reg_m`p_insert within b4w_reg_deposit_limitcontrol
end type

type p_save from w_a_reg_m`p_save within b4w_reg_deposit_limitcontrol
end type

type dw_detail from w_a_reg_m`dw_detail within b4w_reg_deposit_limitcontrol
string dataobject = "b4dw_reg_det_deposit_limitcontrol"
end type

event dw_detail::itemchanged;call super::itemchanged;//String ls_filenm
//
//Choose Case dwo.name
//	Case "email_yn"		
//			If Match (Data, "Y") Then
//				
//				This.Object.filenm[row].Background.Color = RGB(108, 147, 137)		
//	   	Else
//				This.Object.filenm.Background.Color = RGB(255,255,255)		
//			End If
//	End Choose


end event

type p_reset from w_a_reg_m`p_reset within b4w_reg_deposit_limitcontrol
end type

