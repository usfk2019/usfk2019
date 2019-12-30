$PBExportHeader$b1w_reg_sendemail.srw
$PBExportComments$[kem] BroadCasting Email
forward
global type b1w_reg_sendemail from w_a_reg_m_m
end type
type p_fileread from u_p_fileread within b1w_reg_sendemail
end type
type gb_master from groupbox within b1w_reg_sendemail
end type
end forward

global type b1w_reg_sendemail from w_a_reg_m_m
integer width = 3246
integer height = 2168
string is_default = ""
string is_close = ""
event ue_fileread ( )
p_fileread p_fileread
gb_master gb_master
end type
global b1w_reg_sendemail b1w_reg_sendemail

type variables
String is_priceplan		//Price Plan Code
String is_actstatus
Boolean ib_save
String is_date_check  //개통일 Check 여부

end variables

forward prototypes
public subroutine of_resizepanels ()
end prototypes

event ue_fileread();//승인 요청 된 파일 불러옴
Constant Integer li_MAX_DIR = 255
String ls_filename, ls_pathname, ls_curdir
Int li_rc
Long ll_row
Boolean	lb_return

u_api lu_api
lu_api = Create u_api

ls_curdir = Space(li_MAX_DIR)
lu_api.GetCurrentDirectoryA(li_MAX_DIR, ls_curdir)
ls_curdir = Trim(ls_curdir)

//파일 선택
li_rc = GetFileOpenName("Select File" , ls_pathname, ls_filename, '', &
						'Text Files(*.TXT), *.TXT')
						
If li_rc <> 1 Then
	If LenA(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
	Destroy lu_api
	f_msg_info(1001, Title, ls_filename)
	Return
End If

dw_detail.Reset()
ll_row= dw_detail.RowCount()
// modified by hcjung 2007-03-14
li_rc = dw_detail.importfile(ls_pathname)
If li_rc < 0 Then
	f_msg_info(9000, Title, string(li_rc) + "적합하지 않은 파일입니다. 확인 바랍니다.")
	Return
End If

If LenA(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
Destroy lu_api
ls_pathname = ""

dw_cond.Enabled = False
dw_master.InsertRow(0)
p_insert.TriggerEvent('ue_enable')
p_delete.TriggerEvent('ue_enable')
p_save.TriggerEvent('ue_enable') 
p_reset.TriggerEvent('ue_enable') 
end event

public subroutine of_resizepanels ();// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.

// Validate the controls.
If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return

// Top processing
idrg_Top.Move(dw_cond.x, ii_WindowTop)
idrg_Top.Resize(dw_cond.Width + 350, st_horizontal.Y - idrg_Top.Y - 20)

// Bottom Procesing
idrg_Bottom.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
idrg_Bottom.Resize(idrg_Top.Width + 500, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness - iu_cust_w_resize.ii_button_space)
end subroutine

on b1w_reg_sendemail.create
int iCurrent
call super::create
this.p_fileread=create p_fileread
this.gb_master=create gb_master
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_fileread
this.Control[iCurrent+2]=this.gb_master
end on

on b1w_reg_sendemail.destroy
call super::destroy
destroy(this.p_fileread)
destroy(this.gb_master)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_sendemail
	Desc.	: 	BroadCasting Email
	Ver.	:	1.0
	Date	: 	2003.12.11
	Programer : kem
--------------------------------------------------------------------------*/

end event

event ue_ok();call super::ue_ok;String ls_value, ls_name, ls_stitle, ls_birthfr, ls_birthto, ls_method, ls_bilcycle
String ls_where, ls_ctype1, ls_ctype2, ls_location, ls_clevel, ls_svccod, ls_priceplan, ls_status
String ls_activefr, ls_activeto, ls_termfr, ls_termto, ls_prefixno
Date ld_birthfr, ld_birthto
Long ll_row

String		ls_base,		ls_over_status, ls_modify_date
ls_base     	= Trim(dw_cond.object.base[1])
ls_over_status = Trim(dw_cond.object.over_status[1])
ls_modify_date = String(dw_cond.object.modify_date[1],'yyyymmdd')
If IsNull(ls_base) 			Then ls_base 			= ""
If IsNull(ls_over_status) 	Then ls_over_status 	= ""
If IsNull(ls_modify_date)	Then ls_modify_date	= ""

ls_value     = Trim(dw_cond.object.value[1])
ls_name      = Trim(dw_cond.object.name[1])
ls_stitle    = Trim(dw_cond.object.stitle[1])
ls_birthfr   = "" //Trim(dw_cond.object.birthfr[1])
ls_birthto   = "" //Trim(dw_cond.object.birthto[1])
ls_method    = Trim(dw_cond.object.method[1])
ls_bilcycle  = "" //Trim(dw_cond.object.bilcycle[1])
ls_ctype1    = Trim(dw_cond.object.ctype1[1])
ls_ctype2    = Trim(dw_cond.object.ctype2[1])
ls_location  = "" //Trim(dw_cond.object.location[1])
ls_clevel    = Trim(dw_cond.object.clevel[1])
ls_activefr  = String(dw_cond.object.activefr[1], 'yyyymmdd')
ls_activeto  = String(dw_cond.object.activeto[1], 'yyyymmdd')
ls_termfr    = String(dw_cond.object.termfr[1], 'yyyymmdd')
ls_termto    = String(dw_cond.object.termto[1], 'yyyymmdd')
ls_svccod    = Trim(dw_cond.object.svccod[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_status    = Trim(dw_cond.object.status[1])
ls_prefixno  = "" //Trim(dw_cond.object.reg_partner[1])

//Null Check
If IsNull(ls_value) Then ls_value = ""
If IsNull(ls_name) Then ls_name = ""
If IsNull(ls_stitle) Then ls_stitle = ""
If IsNull(ls_birthfr) Then ls_birthfr = ""
If IsNull(ls_birthto) Then ls_birthto = ""
If IsNull(ls_method) Then ls_method = ""
If IsNull(ls_bilcycle) Then ls_bilcycle = ""
If IsNull(ls_ctype1) Then ls_ctype1 = ""
If IsNull(ls_ctype2) Then ls_ctype2 = ""
If IsNull(ls_location) Then ls_location = ""
If IsNull(ls_clevel) Then ls_clevel = ""
If IsNull(ls_activefr) Then ls_activefr = ""
If IsNull(ls_activeto) Then ls_activeto = ""
If IsNull(ls_termfr) Then ls_termfr = ""
If IsNull(ls_termto) Then ls_termto = ""
If IsNull(ls_svccod) Then ls_svccod = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_status) Then ls_status = ""
If IsNull(ls_prefixno) Then ls_prefixno = ""


//날짜 체크
If ls_birthfr <> "" Then
	If IsDate('2003/' + LeftA(ls_birthfr,2) + '/' + RightA(ls_birthfr,2)) = False Then
		f_msg_usr_err(210, Title, "생일")
		dw_cond.SetFocus()
		dw_cond.setColumn("birthfr")
		Return
	End If
	ld_birthfr = Date("2003-" + LeftA(ls_birthfr,2) + "-" + RightA(ls_birthfr,2))
End If

If ls_birthto <> "" Then
	If IsDate('2003/' + LeftA(ls_birthto,2) + '/' + RightA(ls_birthto,2)) = False Then
		f_msg_usr_err(210, Title, "생일")
		dw_cond.SetFocus()
		dw_cond.setColumn("birthto")
		Return
	End If
	ld_birthto = Date("2003-" + LeftA(ls_birthto,2) + "-" + RightA(ls_birthto,2))
End If

If ls_birthfr <> "" And ls_birthto <> "" Then
	If fi_chk_frto_day(ld_birthfr, ld_birthto) < 0 Then
		f_msg_usr_err(211, Title, "생일")
		dw_cond.SetFocus()
		dw_cond.setColumn("birthfr")
		Return
	End If
ElseIf ls_birthfr <> "" And ls_birthto = "" Then
	ls_birthto = "1231"
ElseIf ls_birthfr = "" And ls_birthto <> "" Then
	ls_birthfr = "0101"
End If


ls_where = ""

If ls_value <> "" Then
	If ls_where <> "" Then ls_where += " And "
	Choose Case ls_value
		Case "customerid"
			ls_where += " a.customerid like '" + ls_name + "%' "
		Case "customernm"
			ls_where += "Upper(a.customernm) like '%" + Upper(ls_name) + "%' "
		Case "email"
			ls_where += "Upper(a.EMAIL1) like '%" + Upper(ls_name) + "%' "
		Case "logid"
			ls_where += "Upper(a.logid) like '%" + Upper(ls_name) + "%' "
		Case "bil_mail"
			ls_where += "Upper(b.bil_email) like '%" + Upper(ls_name) + "%' "
		Case "cellphone"
			ls_where += "Upper(a.cellphone) like '%" + Upper(ls_name) + "%' "
		Case "buildingno"
			ls_where += "Upper(a.buildingno) like '%" + Upper(ls_name) + "%' "
		Case "roomno"
			ls_where += "Upper(a.roomno) like '%" + Upper(ls_name) + "%' "
	End Choose		
End If

If ls_stitle <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.stitle = '" + ls_stitle + "' "
End If

If ls_birthfr <> "" And ls_birthto <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(a.birthdt, 'mmdd') >= '" + ls_birthfr + "' "
	ls_where += " And to_char(a.birthdt, 'mmdd') <= '" + ls_birthto + "' "
End If

If ls_ctype1 <> "" Then
	If ls_where <> "" Then ls_where += " And "  
	ls_where += " a.ctype1 = '" + ls_ctype1 + "' "
End if

If ls_ctype2 <> "" Then
	If ls_where <> "" Then ls_where += " And "  
	ls_where += " a.ctype2 = '" + ls_ctype2 + "' "
End if

If ls_location <> "" Then
	If ls_where <> "" Then ls_where += " And "  
	ls_where += " a.location = '" + ls_location + "' "
End if

If ls_clevel <> "" Then
	If ls_where <> "" Then ls_where += " And "  
	ls_where += " a.clevel = '" + ls_clevel + "' "
End if

If ls_method <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += " b.pay_method = '" + ls_method + "' "
End If

If ls_bilcycle <> "" Then
	If ls_where <> "" Then ls_where += " And "  
	ls_where += " b.bilcycle = '" + ls_bilcycle + "' "
End if

If ls_prefixno <> "" Then
	If ls_where <> "" Then ls_where += " And "  
	ls_where += " c.reg_prefixno Like '" + ls_prefixno + "%' "
End if

If ls_activefr <> "" And ls_activeto <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(c.activedt, 'yyyymmdd') >= '" + ls_activefr + "' "
	ls_where += " And to_char(c.activedt, 'yyyymmdd') <= '" + ls_activeto + "' "
	
ElseIf ls_activefr <> "" And ls_activeto = "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(c.activedt, 'yyyymmdd') >= '" + ls_activefr + "' "
	
ElseIf ls_activefr = "" And ls_activeto <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(c.activedt, 'yyyymmdd') <= '" + ls_activeto + "' "
End If

If ls_termfr <> "" And ls_termto <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(c.termdt, 'yyyymmdd') >= '" + ls_termfr + "' "
	ls_where += " And to_char(c.termdt, 'yyyymmdd') <= '" + ls_termto + "' "
	
ElseIf ls_termfr <> "" And ls_termto = "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(c.termdt, 'yyyymmdd') >= '" + ls_termfr + "' "
	
ElseIf ls_termfr = "" And ls_termto <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(c.termdt, 'yyyymmdd') <= '" + ls_termto + "' "
End If

If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " And "  
	ls_where += " c.svccod = '" + ls_svccod + "' "
End if

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "  
	ls_where += " c.priceplan = '" + ls_priceplan + "' "
End if

If ls_status <> "" Then
	If ls_where <> "" Then ls_where += " And "  
	ls_where += " c.status = '" + ls_status + "' "
End if

// ADD  - 2006-12-06
//FROM 정희찬
If ls_base <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " a.basecod = '" + ls_base + "' "
End If
If ls_over_status <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " d.status = '" + ls_over_status + "' "
End If

// Add by hcjung 2007-03-13
If ls_modify_date <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(d.modify_date,'yyyymmdd') = '" + ls_modify_date + "' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
    Return
End If

dw_cond.Enabled = False
dw_master.InsertRow(0)
p_insert.TriggerEvent('ue_enable')
p_delete.TriggerEvent('ue_enable')
p_save.TriggerEvent('ue_enable') 
p_reset.TriggerEvent('ue_enable') 

end event

event type integer ue_extra_save();//Save Check
String ls_activedt, ls_bil_fromdt, ls_sysdt, ls_customerid, ls_chk
Long ll_rows , ll_rc, ll_row, ll_cnt, i
b1u_dbmgr6 lu_dbmgr6

dw_master.AcceptText()
dw_detail.AcceptText()


ll_rows = dw_detail.RowCount()
If ll_rows = 0 Then Return 0

For ll_row = 1 To dw_detail.RowCount()
	ls_chk = dw_detail.object.chk[ll_row]
	
	If ls_chk = 'Y' Then
		ll_cnt ++
	End If
Next

If ll_cnt = 0 Then
	f_msg_info(9000, Title, "E-Mail 전송을 위한 고객을 선택하지 않았습니다.")
	Return -1
End If


lu_dbmgr6 = CREATE b1u_dbmgr6

lu_dbmgr6.is_caller = "b1w_reg_sendemail%save"
lu_dbmgr6.is_title  = Title
lu_dbmgr6.idw_data[1] = dw_master
lu_dbmgr6.idw_data[2] = dw_detail

lu_dbmgr6.uf_prc_db()
ll_rc = lu_dbmgr6.ii_rc

If ll_rc < 0 Then
	dw_master.SetItemStatus(1, 0, Primary!, NotModified!)
	For i = 1 To dw_detail.RowCount()
		dw_detail.SetItemStatus(i, 0, Primary!, NotModified!)
	Next
	Destroy lu_dbmgr6
	Return ll_rc
End If

dw_master.SetItemStatus(1, 0, Primary!, NotModified!)
For i = 1 To dw_detail.RowCount()
	dw_detail.SetItemStatus(i, 0, Primary!, NotModified!)
Next

Destroy lu_dbmgr6

Return 0
end event

event type integer ue_save();//dw_detail을 save 하는 것이 아니므로 조상 스트립트 수정!!
Long ll_row
Int li_rc

Constant Int LI_ERROR = -1

If dw_master.AcceptText() < 0 And dw_detail.AcceptText() < 0 Then
	dw_master.SetFocus()
	Return LI_ERROR
End if

li_rc = This.Trigger Event ue_extra_save()

If li_rc < 0 Then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc < 0 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	// add by hcjung 2007-03-13
	If li_rc <> -3 Then
		f_msg_info(3010,This.Title,"SendEmail")
	End If
	Return LI_ERROR
ElseIf li_rc = 0 Then
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3000,This.Title,"SendEmail")
ElseIF li_rc = -2 Then
	Return LI_ERROR
ElseIf li_rc = -3 Then
	Return LI_ERROR
End if

//Reset
Trigger Event ue_reset()

Return 0
end event

event resize;call super::resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
  
	p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
 
	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1 
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If


SetRedraw(True)
end event

event type integer ue_reset();call super::ue_reset;dw_master.InsertRow(0)

Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;
dw_detail.object.chk[al_insert_row] = 'Y'

Return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_sendemail
integer x = 64
integer y = 52
integer width = 2185
integer height = 740
string dataobject = "b1dw_cnd_sendemail"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild ldc_priceplan
Integer li_exist
String  ls_filter


Choose Case dwo.name
	Case "svccod"
		
		If IsNull(data) Or data = "" Then
			
		Else
			li_exist = dw_cond.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
			If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
			ls_filter = "svccod = '" + data + "' " 
			ldc_priceplan.SetTransObject(SQLCA)
			li_exist =ldc_priceplan.Retrieve()
			ldc_priceplan.SetFilter(ls_filter)			//Filter정함
			ldc_priceplan.Filter()
			
			If li_exist < 0 Then 				
			  f_msg_usr_err(2100, Title, "Retrieve()")
			  Return 1  		//선택 취소 focus는 그곳에
			End If
			
		End If
		
End Choose
end event

event dw_cond::ue_init();call super::ue_init;String ls_emp_grp,		ls_basecod

select emp_group   into :ls_emp_grp  from sysusr1t 
 where emp_id =  :gs_user_id ;
//
IF IsNull(ls_emp_grp) then ls_emp_grp = ''

IF ls_emp_grp <> '' then
	select basecod 	  INTO :ls_basecod	  FROM partnermst
	 WHERE basecod = :ls_emp_grp    ;
	 
	 IF sqlca.sqlcode <> 0 OR IsNull(ls_basecod) then ls_basecod = '000000'
EnD IF
dw_cond.reset()


end event

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_sendemail
integer x = 2331
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_sendemail
integer x = 2331
integer y = 172
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_sendemail
integer x = 18
integer width = 2277
integer height = 800
integer taborder = 20
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_sendemail
integer x = 41
integer y = 828
integer width = 2313
integer height = 452
integer taborder = 30
string dataobject = "b1dw_reg_sendemail_master"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
boolean hsplitscroll = false
boolean livescroll = false
borderstyle borderstyle = stylelowered!
end type

event dw_master::clicked;//
end event

event type integer dw_master::ue_after_sort();//

Return 0
end event

event dw_master::retrieveend;//
end event

event dw_master::ue_init();//
end event

event dw_master::constructor;SetTransObject(SQLCA)

Trigger Event ue_init()

This.SetRowFocusIndicator(Off!)
end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_sendemail
integer x = 23
integer y = 1348
integer width = 3131
integer height = 564
integer taborder = 40
string dataobject = "b1dw_reg_sendemail_detail"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event dw_detail::doubleclicked;call super::doubleclicked;Choose Case dwo.Name
	Case "customerid"
		If iu_cust_help.ib_data[1] Then
			Object.customerid[row] = iu_cust_help.is_data[1]
			Object.customernm[row] = iu_cust_help.is_data[2]
		End If
End Choose
end event

event dw_detail::ue_init();call super::ue_init;idwo_help_col[1] = Object.customerid
is_help_win[1] = "b1w_hlp_customerm"
is_data[1] = "CloseWithReturn"
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_sendemail
integer y = 1936
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_sendemail
integer y = 1936
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_sendemail
integer x = 617
integer y = 1936
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_sendemail
integer x = 905
integer y = 1936
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_sendemail
integer x = 18
integer y = 1296
integer height = 40
end type

type p_fileread from u_p_fileread within b1w_reg_sendemail
integer x = 2331
integer y = 292
boolean bringtotop = true
boolean originalsize = false
end type

type gb_master from groupbox within b1w_reg_sendemail
integer x = 18
integer y = 780
integer width = 2647
integer height = 512
integer taborder = 50
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
borderstyle borderstyle = stylelowered!
end type

